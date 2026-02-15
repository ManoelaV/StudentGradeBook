"""
Módulo de gerenciamento do banco de dados SQLite para o Student GradeBook.
Funciona completamente offline.
"""

import sqlite3
import os
from datetime import datetime


class Database:
    """Classe para gerenciar todas as operações do banco de dados."""
    
    def __init__(self, db_name="student_gradebook.db"):
        """Inicializa a conexão com o banco de dados."""
        self.db_name = db_name
        self.conn = None
        self.cursor = None
        self.connect()
        self.create_tables()
    
    def connect(self):
        """Estabelece conexão com o banco de dados."""
        self.conn = sqlite3.connect(self.db_name)
        self.cursor = self.conn.cursor()
    
    def _normalize_name(self, name):
        """Normaliza nomes de escola/turma para evitar duplicatas por diferença de capitalização.
        Converte para Title Case (primeira letra de cada palavra maiúscula).
        Exemplo: 'escola bruno chaves' -> 'Escola Bruno Chaves'
        """
        if not name:
            return name
        return ' '.join(word.capitalize() for word in name.strip().split())
    
    def create_tables(self):
        """Cria as tabelas necessárias se não existirem."""
        # Tabela de alunos
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                registration_number TEXT UNIQUE,
                school TEXT,
                class TEXT,
                photo_path TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabela de notas
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS grades (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                student_id INTEGER NOT NULL,
                subject TEXT NOT NULL,
                grade REAL NOT NULL,
                max_grade REAL DEFAULT 10.0,
                date DATE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
            )
        ''')
        
        # Tabela de observações
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS observations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                student_id INTEGER NOT NULL,
                observation TEXT NOT NULL,
                date DATE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
            )
        ''')
        
        self.conn.commit()
        self.migrate_database()
        self.normalize_existing_data()
    
    def normalize_existing_data(self):
        """Normaliza nomes de escola e turma existentes no banco de dados para evitar duplicatas."""
        try:
            self.cursor.execute('SELECT id, school, class FROM students')
            rows = self.cursor.fetchall()
            
            for row_id, school, class_name in rows:
                normalized_school = self._normalize_name(school) if school else None
                normalized_class = self._normalize_name(class_name) if class_name else None
                
                # Só atualizar se houver mudança
                if (school != normalized_school) or (class_name != normalized_class):
                    self.cursor.execute('''
                        UPDATE students SET school = ?, class = ? WHERE id = ?
                    ''', (normalized_school, normalized_class, row_id))
            
            self.conn.commit()
        except Exception as e:
            pass  # Erro na normalização, continuando
    
    def migrate_database(self):
        """Migra banco de dados antigo para nova estrutura com school e class nas posições corretas"""
        try:
            # Verificar se a tabela students existe
            self.cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='students'")
            if not self.cursor.fetchone():
                return  # Tabela nova, nada a migrar
            
            # Verificar a ordem das colunas
            self.cursor.execute("PRAGMA table_info(students)")
            columns = [column[1] for column in self.cursor.fetchall()]
            
            # Se school/class estão no final (ordem errada), fazer backup e reconstruir
            if len(columns) > 6 and columns != ['id', 'name', 'registration_number', 'school', 'class', 'photo_path', 'created_at', 'updated_at']:
                # Fazer backup dos dados
                self.cursor.execute('SELECT id, name, registration_number, photo_path, created_at, updated_at FROM students')
                backup_data = self.cursor.fetchall()
                
                # Deletar tabela antiga e reconstruir
                self.cursor.execute('DROP TABLE IF EXISTS students')
                self.cursor.execute('''
                    CREATE TABLE students (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT NOT NULL,
                        registration_number TEXT UNIQUE,
                        school TEXT,
                        class TEXT,
                        photo_path TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                ''')
                
                # Restaurar dados
                for row in backup_data:
                    self.cursor.execute('''
                        INSERT INTO students (id, name, registration_number, school, class, photo_path, created_at, updated_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (row[0], row[1], row[2], None, None, row[3], row[4], row[5]))
                
                self.conn.commit()
            elif 'school' not in columns:
                self.cursor.execute("ALTER TABLE students ADD COLUMN school TEXT")
            
            if 'class' not in columns:
                self.cursor.execute("ALTER TABLE students ADD COLUMN class TEXT")
            
            self.conn.commit()
        except Exception as e:
            pass  # Erro na migração, continuando
    
    # OPERAÇÕES COM ALUNOS
    def add_student(self, name, registration_number=None, school=None, class_name=None, photo_path=None):
        """Adiciona um novo aluno ao banco de dados.
        Normaliza os nomes de escola e turma para evitar duplicatas por diferença de capitalização."""
        try:
            # Normalizar nomes de escola e turma
            school = self._normalize_name(school) if school else None
            class_name = self._normalize_name(class_name) if class_name else None
            
            self.cursor.execute('''
                INSERT INTO students (name, registration_number, school, class, photo_path)
                VALUES (?, ?, ?, ?, ?)
            ''', (name, registration_number, school, class_name, photo_path))
            self.conn.commit()
            return self.cursor.lastrowid
        except sqlite3.IntegrityError:
            return None  # Número de matrícula já existe
    
    def get_all_students(self):
        """Retorna todos os alunos cadastrados."""
        self.cursor.execute('SELECT * FROM students ORDER BY name')
        return self.cursor.fetchall()
    
    def get_student_by_id(self, student_id):
        """Retorna um aluno específico pelo ID."""
        self.cursor.execute('SELECT * FROM students WHERE id = ?', (student_id,))
        return self.cursor.fetchone()
    
    def update_student(self, student_id, name=None, registration_number=None, school=None, class_name=None, photo_path=None):
        """Atualiza os dados de um aluno.
        Normaliza os nomes de escola e turma para evitar duplicatas por diferença de capitalização."""
        updates = []
        values = []
        
        if name is not None:
            updates.append("name = ?")
            values.append(name)
        if registration_number is not None:
            updates.append("registration_number = ?")
            values.append(registration_number)
        if school is not None:
            updates.append("school = ?")
            values.append(self._normalize_name(school))
        if class_name is not None:
            updates.append("class = ?")
            values.append(self._normalize_name(class_name))
        if photo_path is not None:
            updates.append("photo_path = ?")
            values.append(photo_path)
        
        if updates:
            updates.append("updated_at = CURRENT_TIMESTAMP")
            values.append(student_id)
            query = f"UPDATE students SET {', '.join(updates)} WHERE id = ?"
            self.cursor.execute(query, values)
            self.conn.commit()
            return True
        return False
    
    def delete_student(self, student_id):
        """Remove um aluno do banco de dados."""
        self.cursor.execute('DELETE FROM students WHERE id = ?', (student_id,))
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    # OPERAÇÕES COM NOTAS
    def add_grade(self, student_id, subject, grade, max_grade=10.0, date=None):
        """Adiciona uma nota para um aluno."""
        if date is None:
            date = datetime.now().strftime('%Y-%m-%d')
        
        self.cursor.execute('''
            INSERT INTO grades (student_id, subject, grade, max_grade, date)
            VALUES (?, ?, ?, ?, ?)
        ''', (student_id, subject, grade, max_grade, date))
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_student_grades(self, student_id):
        """Retorna todas as notas de um aluno."""
        self.cursor.execute('''
            SELECT * FROM grades 
            WHERE student_id = ? 
            ORDER BY date DESC, subject
        ''', (student_id,))
        return self.cursor.fetchall()
    
    def update_grade(self, grade_id, subject=None, grade=None, max_grade=None, date=None):
        """Atualiza uma nota."""
        updates = []
        values = []
        
        if subject is not None:
            updates.append("subject = ?")
            values.append(subject)
        if grade is not None:
            updates.append("grade = ?")
            values.append(grade)
        if max_grade is not None:
            updates.append("max_grade = ?")
            values.append(max_grade)
        if date is not None:
            updates.append("date = ?")
            values.append(date)
        
        if updates:
            values.append(grade_id)
            query = f"UPDATE grades SET {', '.join(updates)} WHERE id = ?"
            self.cursor.execute(query, values)
            self.conn.commit()
            return True
        return False
    
    def delete_grade(self, grade_id):
        """Remove uma nota."""
        self.cursor.execute('DELETE FROM grades WHERE id = ?', (grade_id,))
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    def get_student_total(self, student_id, subject=None):
        """Calcula o somatório de pontos (notas) de um aluno."""
        if subject:
            self.cursor.execute('''
                SELECT SUM(grade) 
                FROM grades 
                WHERE student_id = ? AND subject = ?
            ''', (student_id, subject))
        else:
            self.cursor.execute('''
                SELECT SUM(grade) 
                FROM grades 
                WHERE student_id = ?
            ''', (student_id,))
        
        result = self.cursor.fetchone()
        return round(result[0], 2) if result[0] is not None else 0.0
    
    # OPERAÇÕES COM OBSERVAÇÕES
    def add_observation(self, student_id, observation, date=None):
        """Adiciona uma observação para um aluno."""
        if date is None:
            date = datetime.now().strftime('%Y-%m-%d')
        
        self.cursor.execute('''
            INSERT INTO observations (student_id, observation, date)
            VALUES (?, ?, ?)
        ''', (student_id, observation, date))
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_student_observations(self, student_id):
        """Retorna todas as observações de um aluno."""
        self.cursor.execute('''
            SELECT * FROM observations 
            WHERE student_id = ? 
            ORDER BY date DESC
        ''', (student_id,))
        return self.cursor.fetchall()
    
    def update_observation(self, observation_id, observation=None, date=None):
        """Atualiza uma observação."""
        updates = []
        values = []
        
        if observation is not None:
            updates.append("observation = ?")
            values.append(observation)
        if date is not None:
            updates.append("date = ?")
            values.append(date)
        
        if updates:
            updates.append("updated_at = CURRENT_TIMESTAMP")
            values.append(observation_id)
            query = f"UPDATE observations SET {', '.join(updates)} WHERE id = ?"
            self.cursor.execute(query, values)
            self.conn.commit()
            return True
        return False
    
    def delete_observation(self, observation_id):
        """Remove uma observação."""
        self.cursor.execute('DELETE FROM observations WHERE id = ?', (observation_id,))
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    def close(self):
        """Fecha a conexão com o banco de dados."""
        if self.conn:
            self.conn.close()
