"""
Student GradeBook - Versão Tkinter (sem problemas de dependências)
Interface simples e funcional para gerenciar notas de alunos
Funciona 100% offline com banco de dados SQLite local
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import os
import shutil
from database import Database
from datetime import datetime
from PIL import Image, ImageTk

class StudentGradeBook:
    def __init__(self, root):
        self.root = root
        self.root.title('📚 Caderneta de Notas - Student GradeBook')
        self.root.geometry('1000x800')
        self.db = Database()
        self.current_student = None
        
        # Configurar estilo para Treeviews
        self.setup_styles()
        
        self.show_student_list()
    
    def setup_styles(self):
        """Configura estilos visuais para Treeviews com melhor aparência"""
        style = ttk.Style()
        
        # Configurar estilo para Treeview com linhas visíveis
        style.configure('Treeview',
                       rowheight=30,  # Aumentar altura das linhas
                       font=('Arial', 10),
                       borderwidth=1,
                       relief='solid')
        style.configure('Treeview.Heading',
                       font=('Arial', 11, 'bold'),
                       background='#d0d0d0',
                       borderwidth=2,
                       relief='solid',
                       padding=5)
        
        # Mapear cores para melhor visualização com cores alternadas
        style.map('Treeview',
                 background=[('selected', '#0078d4'), ('alternate', '#f0f0f0')],
                 foreground=[('selected', 'white')])
        
        style.map('Treeview.Heading',
                 background=[('active', '#c0c0c0')])
    
    def clear_window(self):
        """Limpa a janela"""
        for widget in self.root.winfo_children():
            widget.destroy()
    
    def show_student_list(self):
        """Tela principal - lista de alunos organizada por escola e turma"""
        self.clear_window()
        
        # Frame superior
        top_frame = ttk.Frame(self.root)
        top_frame.pack(fill=tk.X, padx=10, pady=10)
        
        ttk.Label(top_frame, text='📚 Caderneta de Notas', font=('Arial', 18, 'bold')).pack(side=tk.LEFT)
        ttk.Button(top_frame, text='+ Novo Aluno', command=lambda: self.show_add_student_window()).pack(side=tk.RIGHT, padx=5)
        
        # Frame de pesquisa
        search_frame = ttk.Frame(self.root)
        search_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(search_frame, text='🔍 Pesquisar:', font=('Arial', 10)).pack(side=tk.LEFT, padx=5)
        self.search_entry = ttk.Entry(search_frame, width=40)
        self.search_entry.pack(side=tk.LEFT, padx=5)
        
        def clear_search():
            self.search_entry.delete(0, tk.END)
            self.search_entry.focus()
            self.on_search_change()
        
        ttk.Button(search_frame, text='Limpar', command=clear_search).pack(side=tk.LEFT, padx=2)
        
        # Frame com scrollbar
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Criar Treeview para listar alunos hierarquicamente
        columns = ('Matrícula', 'Total')
        self.tree = ttk.Treeview(main_frame, columns=columns, height=20, style='Treeview')
        self.tree.column('#0', width=350, stretch=tk.NO)
        self.tree.column('Matrícula', anchor=tk.CENTER, width=150)
        self.tree.column('Total', anchor=tk.CENTER, width=100)
        
        self.tree.heading('#0', text='Escola / Turma / Aluno', anchor=tk.W)
        self.tree.heading('Matrícula', text='Matrícula', anchor=tk.W)
        self.tree.heading('Total', text='Total', anchor=tk.W)
        
        # Configurar cores para diferentes níveis
        self.tree.tag_configure('school', font=('Arial', 10, 'bold'), foreground='#1f497d')
        self.tree.tag_configure('class', font=('Arial', 10), foreground='#404040')
        self.tree.tag_configure('student_even', background='white')
        self.tree.tag_configure('student_odd', background='#f0f0f0')
        
        # Scrollbar
        scrollbar = ttk.Scrollbar(main_frame, orient=tk.VERTICAL, command=self.tree.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree.configure(yscroll=scrollbar.set)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Adicionar binding para duplo clique abrir detalhes
        self.tree.bind('<Double-1>', self.on_double_click)
        
        # Armazenar dados originais para filtragem
        self.all_students = self.db.get_all_students()
        self.students_data = {}
        
        # Bind do evento de digitação na entrada de pesquisa
        self.search_entry.bind('<KeyRelease>', lambda e: self.on_search_change())
        
        # Preenchendo dados organizados por escola e turma (sem filtro inicialmente)
        self.populate_tree('')
        
        # Frame inferior com botões
        bottom_frame = ttk.Frame(self.root)
        bottom_frame.pack(fill=tk.X, padx=10, pady=10)
        
        ttk.Button(bottom_frame, text='Ver Detalhes', 
                  command=self.on_view_student).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom_frame, text='Editar', 
                  command=self.on_edit_student).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom_frame, text='Excluir', 
                  command=self.on_delete_student).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom_frame, text='Atualizar', 
                  command=self.show_student_list).pack(side=tk.LEFT, padx=5)
    
    def on_search_change(self):
        """Atualizar pesquisa quando o texto muda"""
        search_term = self.search_entry.get().lower().strip()
        self.populate_tree(search_term)
    
    def populate_tree(self, search_term=''):
        """Popula a Treeview com alunos, filtrados opcionalmente por termo de busca"""
        # Limpar treeview
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        self.students_data = {}
        
        if not self.all_students:
            self.tree.insert('', 'end', text='Nenhum aluno cadastrado', values=('', ''))
            return
        
        # Filtrar alunos baseado no termo de busca
        filtered_students = []
        for student in self.all_students:
            student_id, name, reg_num, school, class_name, photo_path, _, _ = student
            
            # Pesquisar em: nome, matrícula, escola, turma
            search_fields = [
                name.lower() if name else '',
                (reg_num.lower() if reg_num else ''),
                (school.lower() if school else ''),
                (class_name.lower() if class_name else '')
            ]
            
            # Se o termo de busca está em qualquer um dos campos, incluir
            if not search_term or any(search_term in field for field in search_fields):
                filtered_students.append(student)
        
        if not filtered_students:
            self.tree.insert('', 'end', text=f'Nenhum aluno encontrado para "{search_term}"', values=('', ''))
            return
        
        # Agrupar alunos por escola e turma
        schools_dict = {}
        for student in filtered_students:
            student_id, name, reg_num, school, class_name, photo_path, _, _ = student
            school = school or 'Sem Escola'
            class_name = class_name or 'Sem Turma'
            
            if school not in schools_dict:
                schools_dict[school] = {}
            if class_name not in schools_dict[school]:
                schools_dict[school][class_name] = []
            
            schools_dict[school][class_name].append({
                'id': student_id,
                'name': name,
                'reg_num': reg_num,
                'total': self.db.get_student_total(student_id)
            })
        
        # Inserir na Treeview
        for school in sorted(schools_dict.keys()):
            school_item = self.tree.insert('', 'end', text=f'🏫 {school}', values=('', ''), tags=('school',))
            
            for class_name in sorted(schools_dict[school].keys()):
                class_item = self.tree.insert(school_item, 'end', text=f'  📖 {class_name}', values=('', ''), tags=('class',))
                
                for idx, student in enumerate(schools_dict[school][class_name]):
                    # Alternar cores dos alunos
                    tag = 'student_even' if idx % 2 == 0 else 'student_odd'
                    student_item = self.tree.insert(class_item, 'end', 
                                                   text=f'    {student["name"]}',
                                                   values=(student['reg_num'] or '-', 
                                                          f'{student["total"]:.2f}'),
                                                   tags=(tag,))
                    self.students_data[student_item] = student['id']
    
    def on_double_click(self, event):
        """Exibir detalhes ao fazer duplo clique no aluno"""
        selected = self.tree.selection()
        if not selected:
            return
        
        item = selected[0]
        # Só abrir detalhes se for um aluno (estiver em students_data)
        if item in self.students_data:
            self.on_view_student()
    
    def on_view_student(self):
        """Exibir detalhes do aluno selecionado"""
        selected = self.tree.selection()
        if not selected:
            messagebox.showerror('Erro', 'Selecione um aluno')
            return
        
        item = selected[0]
        if item not in self.students_data:
            messagebox.showerror('Erro', 'Selecione um aluno, não uma escola ou turma')
            return
        
        student_id = self.students_data[item]
        self.show_student_detail(student_id)
    
    def on_edit_student(self):
        """Editar aluno selecionado"""
        selected = self.tree.selection()
        if not selected:
            messagebox.showerror('Erro', 'Selecione um aluno')
            return
        
        item = selected[0]
        if item not in self.students_data:
            messagebox.showerror('Erro', 'Selecione um aluno, não uma escola ou turma')
            return
        
        student_id = self.students_data[item]
        self.show_add_student_window(student_id)
    
    def on_delete_student(self):
        """Excluir aluno selecionado"""
        selected = self.tree.selection()
        if not selected:
            messagebox.showerror('Erro', 'Selecione um aluno')
            return
        
        item = selected[0]
        if item not in self.students_data:
            messagebox.showerror('Erro', 'Selecione um aluno, não uma escola ou turma')
            return
        
        if messagebox.askyesno('Confirmar', 'Excluir aluno? Todos os dados serão perdidos!'):
            student_id = self.students_data[item]
            self.db.delete_student(student_id)
            self.show_student_list()
    
    def show_add_student_window(self, student_id=None):
        """Janela para adicionar/editar aluno"""
        self.clear_window()
        
        student = None
        title = 'Novo Aluno'
        if student_id:
            student = self.db.get_student_by_id(student_id)
            title = f'Editar Aluno - {student[1]}'
        
        # Frame principal
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        ttk.Label(main_frame, text=title, font=('Arial', 16, 'bold')).grid(row=0, column=0, columnspan=2, pady=10)
        
        # Nome
        ttk.Label(main_frame, text='Nome:').grid(row=1, column=0, sticky=tk.W, pady=5)
        name_entry = ttk.Entry(main_frame, width=40)
        name_entry.grid(row=1, column=1, pady=5)
        if student:
            name_entry.insert(0, student[1])
        
        # Matrícula
        ttk.Label(main_frame, text='Matrícula:').grid(row=2, column=0, sticky=tk.W, pady=5)
        reg_entry = ttk.Entry(main_frame, width=40)
        reg_entry.grid(row=2, column=1, pady=5)
        if student and student[2]:
            reg_entry.insert(0, student[2])
        
        # Escola
        ttk.Label(main_frame, text='Escola:').grid(row=3, column=0, sticky=tk.W, pady=5)
        school_entry = ttk.Entry(main_frame, width=40)
        school_entry.grid(row=3, column=1, pady=5)
        if student and student[3]:
            school_entry.insert(0, student[3])
        
        # Turma
        ttk.Label(main_frame, text='Turma:').grid(row=4, column=0, sticky=tk.W, pady=5)
        class_entry = ttk.Entry(main_frame, width=40)
        class_entry.grid(row=4, column=1, pady=5)
        if student and student[4]:
            class_entry.insert(0, student[4])
        
        # Foto
        ttk.Label(main_frame, text='Foto:').grid(row=5, column=0, sticky=tk.W, pady=5)
        photo_label = ttk.Label(main_frame, text='Nenhuma foto selecionada', foreground='gray')
        photo_label.grid(row=5, column=1, sticky=tk.W, pady=5)
        
        self.selected_photo = None
        if student and student[5] and os.path.exists(student[5]):
            photo_label.config(text=student[5], foreground='black')
            self.selected_photo = student[5]
        
        def select_photo():
            file = filedialog.askopenfilename(
                filetypes=[('Images', '*.png *.jpg *.jpeg'), ('All Files', '*.*')]
            )
            if file:
                self.selected_photo = file
                photo_label.config(text=file, foreground='black')
        
        def clear_photo():
            self.selected_photo = None
            photo_label.config(text='Nenhuma foto selecionada', foreground='gray')
        
        # Botões da foto na mesma linha
        photo_button_frame = ttk.Frame(main_frame)
        photo_button_frame.grid(row=5, column=2, sticky=tk.W, padx=5)
        ttk.Button(photo_button_frame, text='Procurar...', command=select_photo).pack(side=tk.LEFT, padx=2)
        ttk.Button(photo_button_frame, text='Limpar', command=clear_photo).pack(side=tk.LEFT, padx=2)
        
        # Botões
        def save():
            name = name_entry.get().strip()
            reg_num = reg_entry.get().strip() or None
            school = school_entry.get().strip() or None
            class_name = class_entry.get().strip() or None
            
            if not name:
                messagebox.showerror('Erro', 'Digite o nome do aluno')
                return
            
            photo_path = None
            if self.selected_photo and os.path.exists(self.selected_photo):
                if not os.path.exists('photos'):
                    os.makedirs('photos')
                filename = f"student_{name.replace(' ', '_')}_{reg_num or 'noReg'}{os.path.splitext(self.selected_photo)[1]}"
                photo_path = os.path.join('photos', filename)
                try:
                    shutil.copy2(self.selected_photo, photo_path)
                except:
                    photo_path = None
            
            if student_id:
                self.db.update_student(student_id, name, reg_num, school, class_name, photo_path)
                messagebox.showinfo('Sucesso', 'Aluno atualizado!')
            else:
                result = self.db.add_student(name, reg_num, school, class_name, photo_path)
                if result:
                    messagebox.showinfo('Sucesso', 'Aluno cadastrado!')
                else:
                    messagebox.showerror('Erro', 'Matrícula já existe')
                    return
            
            self.show_student_list()
        
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=6, column=0, columnspan=2, pady=20)
        
        ttk.Button(button_frame, text='Salvar', command=save).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text='Cancelar', command=self.show_student_list).pack(side=tk.LEFT, padx=5)
    
    def show_student_detail(self, student_id):
        """Tela de detalhes do aluno"""
        self.clear_window()
        
        student = self.db.get_student_by_id(student_id)
        _, name, reg_num, school, class_name, photo_path, _, _ = student
        total = self.db.get_student_total(student_id)
        
        # Header
        header_frame = ttk.Frame(self.root)
        header_frame.pack(fill=tk.X, padx=10, pady=10)
        
        ttk.Button(header_frame, text='← Voltar', 
                  command=self.show_student_list).pack(side=tk.LEFT, padx=5)
        
        ttk.Label(header_frame, text=f'📌 {name}', font=('Arial', 16, 'bold')).pack(side=tk.LEFT, expand=True)
        ttk.Label(header_frame, text=f'Total: {total:.2f} pontos', font=('Arial', 14, 'bold')).pack(side=tk.LEFT, padx=10)
        
        ttk.Button(header_frame, text='🗑 Excluir Aluno', 
                  command=lambda: self.delete_student_confirm(student_id)).pack(side=tk.RIGHT, padx=5)
        
        # Frame com foto e informações
        info_frame = ttk.Frame(self.root)
        info_frame.pack(fill=tk.X, padx=10, pady=10)
        
        # Foto do aluno
        if photo_path and os.path.exists(photo_path):
            try:
                image = Image.open(photo_path)
                image.thumbnail((150, 150), Image.Resampling.LANCZOS)
                photo_image = ImageTk.PhotoImage(image)
                
                photo_label = ttk.Label(info_frame, image=photo_image)
                photo_label.image = photo_image  # Manter referência
                photo_label.pack(side=tk.LEFT, padx=10, pady=10)
            except:
                ttk.Label(info_frame, text='[Foto não disponível]', font=('Arial', 10)).pack(side=tk.LEFT, padx=10)
        else:
            ttk.Label(info_frame, text='[Sem foto]', font=('Arial', 10)).pack(side=tk.LEFT, padx=10)
        
        # Informações do aluno
        details_frame = ttk.Frame(info_frame)
        details_frame.pack(side=tk.LEFT, padx=10, fill=tk.BOTH, expand=True)
        
        ttk.Label(details_frame, text=f'Matrícula: {reg_num or "N/A"}', font=('Arial', 11)).pack(anchor=tk.W)
        ttk.Label(details_frame, text=f'Escola: {school or "N/A"}', font=('Arial', 11)).pack(anchor=tk.W)
        ttk.Label(details_frame, text=f'Turma: {class_name or "N/A"}', font=('Arial', 11)).pack(anchor=tk.W)
        ttk.Label(details_frame, text=f'Total de Pontos: {total:.2f}', font=('Arial', 11, 'bold')).pack(anchor=tk.W)
        
        # Criar notebook (abas)
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Aba de Notas
        grades_frame = ttk.Frame(notebook)
        notebook.add(grades_frame, text='📝 Notas')
        
        ttk.Button(grades_frame, text='+ Adicionar Nota', 
                  command=lambda: self.add_grade_dialog(student_id)).pack(pady=10)
        
        # Frame para Treeview com scrollbar
        grades_scroll_frame = ttk.Frame(grades_frame)
        grades_scroll_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        grades_tree = ttk.Treeview(grades_scroll_frame, columns=('Matéria', 'Nota', 'Data'), 
                                   height=15, style='Treeview', show='headings')
        grades_tree.column('Matéria', anchor=tk.W, width=250)
        grades_tree.column('Nota', anchor=tk.CENTER, width=150)
        grades_tree.column('Data', anchor=tk.CENTER, width=150)
        grades_tree.heading('Matéria', text='Matéria')
        grades_tree.heading('Nota', text='Nota')
        grades_tree.heading('Data', text='Data')
        
        # Configurar cores alternadas para as linhas
        grades_tree.tag_configure('oddrow', background='white')
        grades_tree.tag_configure('evenrow', background='#f0f0f0')
        
        # Scrollbar para notas
        grades_scrollbar = ttk.Scrollbar(grades_scroll_frame, orient=tk.VERTICAL, command=grades_tree.yview)
        grades_tree.configure(yscroll=grades_scrollbar.set)
        grades_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        grades_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        grades = self.db.get_student_grades(student_id)
        self.grades_data = {}
        for idx, grade in enumerate(grades):
            grade_id, _, subject, grade_value, max_grade, date, _ = grade
            # Alternar cores das linhas
            tag = 'evenrow' if idx % 2 == 0 else 'oddrow'
            item = grades_tree.insert('', 'end', text='', values=(subject, f'{grade_value}/{max_grade}', date), tags=(tag,))
            self.grades_data[item] = grade_id
        
        def delete_grade():
            selected = grades_tree.selection()
            if selected:
                grade_id = self.grades_data[selected[0]]
                self.db.delete_grade(grade_id)
                self.show_student_detail(student_id)
        
        ttk.Button(grades_frame, text='Excluir Nota Selecionada', 
                  command=delete_grade).pack(pady=10)
        
        # Aba de Observações
        obs_frame = ttk.Frame(notebook)
        notebook.add(obs_frame, text='💬 Observações')
        
        ttk.Label(obs_frame, text='Digite suas observações (mínimo 20 linhas disponíveis):').pack(padx=10, pady=10)
        
        # Campo de texto para nova observação
        text_widget = tk.Text(obs_frame, height=12, width=80)
        text_widget.pack(padx=10, pady=5, fill=tk.BOTH, expand=True)
        
        def save_obs():
            obs_text = text_widget.get('1.0', tk.END).strip()
            if obs_text:
                self.db.add_observation(student_id, obs_text)
                text_widget.delete('1.0', tk.END)
                self.show_student_detail(student_id)
            else:
                messagebox.showerror('Erro', 'Digite uma observação')
        
        ttk.Button(obs_frame, text='Salvar Observação', command=save_obs).pack(pady=10)
        
        # Histórico de observações
        ttk.Label(obs_frame, text='Histórico de Observações:', font=('Arial', 10, 'bold')).pack(anchor=tk.W, padx=10)
        
        # Frame para Treeview com scrollbar
        history_frame = ttk.Frame(obs_frame)
        history_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        obs_tree = ttk.Treeview(history_frame, columns=('Data', 'Observação'), height=15, style='Treeview')
        obs_tree.column('Data', anchor=tk.CENTER, width=120)
        obs_tree.column('Observação', anchor=tk.W, width=400)
        obs_tree.heading('Data', text='Data')
        obs_tree.heading('Observação', text='Observação')
        
        # Configurar cores alternadas para as linhas
        obs_tree.tag_configure('oddrow', background='white')
        obs_tree.tag_configure('evenrow', background='#f0f0f0')
        
        # Scrollbar para o histórico
        obs_scrollbar = ttk.Scrollbar(history_frame, orient=tk.VERTICAL, command=obs_tree.yview)
        obs_tree.configure(yscroll=obs_scrollbar.set)
        obs_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        obs_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        observations = self.db.get_student_observations(student_id)
        self.obs_data = {}
        for idx, obs in enumerate(observations):
            obs_id, _, observation, date, _, _ = obs
            obs_text = observation[:100] + '...' if len(observation) > 100 else observation
            # Alternar cores das linhas
            tag = 'evenrow' if idx % 2 == 0 else 'oddrow'
            item = obs_tree.insert('', 'end', text='', values=(date, obs_text), tags=(tag,))
            self.obs_data[item] = obs_id
        
        # Frame para botões
        button_frame = ttk.Frame(obs_frame)
        button_frame.pack(fill=tk.X, padx=10, pady=5)
        
        def view_obs():
            selected = obs_tree.selection()
            if selected:
                obs_id = self.obs_data[selected[0]]
                # Encontrar a observação completa
                for obs in observations:
                    if obs[0] == obs_id:
                        messagebox.showinfo('Observação Completa', obs[2])
                        break
            else:
                messagebox.showwarning('Aviso', 'Selecione uma observação para visualizar')
        
        def delete_obs():
            selected = obs_tree.selection()
            if selected:
                obs_id = self.obs_data[selected[0]]
                self.db.delete_observation(obs_id)
                self.show_student_detail(student_id)
            else:
                messagebox.showwarning('Aviso', 'Selecione uma observação para excluir')
        
        ttk.Button(button_frame, text='Ver Completa', command=view_obs).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text='Excluir Selecionada', command=delete_obs).pack(side=tk.LEFT, padx=5)
    
    def delete_student_confirm(self, student_id):
        """Confirmar exclusão do aluno"""
        if messagebox.askyesno('Confirmar', 'Excluir aluno e todos seus dados?'):
            self.db.delete_student(student_id)
            self.show_student_list()
    
    def add_grade_dialog(self, student_id):
        """Dialog para adicionar nota"""
        dialog = tk.Toplevel(self.root)
        dialog.title('Adicionar Nota')
        dialog.geometry('300x200')
        
        ttk.Label(dialog, text='Matéria:').grid(row=0, column=0, sticky=tk.W, padx=10, pady=5)
        subject_entry = ttk.Entry(dialog, width=25)
        subject_entry.grid(row=0, column=1, padx=10, pady=5)
        
        ttk.Label(dialog, text='Nota:').grid(row=1, column=0, sticky=tk.W, padx=10, pady=5)
        grade_entry = ttk.Entry(dialog, width=25)
        grade_entry.grid(row=1, column=1, padx=10, pady=5)
        
        ttk.Label(dialog, text='Nota Máxima:').grid(row=2, column=0, sticky=tk.W, padx=10, pady=5)
        max_entry = ttk.Entry(dialog, width=25)
        max_entry.insert(0, '10.0')
        max_entry.grid(row=2, column=1, padx=10, pady=5)
        
        def save():
            try:
                subject = subject_entry.get().strip()
                grade = float(grade_entry.get())
                max_grade = float(max_entry.get())
                
                if subject and grade >= 0 and max_grade > 0:
                    self.db.add_grade(student_id, subject, grade, max_grade)
                    messagebox.showinfo('Sucesso', 'Nota adicionada!')
                    dialog.destroy()
                    self.show_student_detail(student_id)
                else:
                    messagebox.showerror('Erro', 'Valores inválidos')
            except ValueError:
                messagebox.showerror('Erro', 'Digite valores numéricos válidos')
        
        ttk.Button(dialog, text='Salvar', command=save).grid(row=3, column=0, columnspan=2, pady=20)

if __name__ == '__main__':
    root = tk.Tk()
    app = StudentGradeBook(root)
    root.mainloop()
