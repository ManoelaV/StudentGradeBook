import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "student_gradebook.db";
  static const _databaseVersion = 11;

  static const String tableSchools = 'schools';
  static const String tableClasses = 'classes';
  static const String tableStudents = 'students';
  static const String tableGrades = 'grades';
  static const String tableObservations = 'observations';
  static const String tableAttendance = 'attendance';
  static const String tableLessonContent = 'lesson_content';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colRegNum = 'registration_number';
  static const String colSchool = 'school';
  static const String colClass = 'class';
  static const String colPhoto = 'photo_path';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableAttendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          school TEXT,
          class TEXT,
          date TEXT NOT NULL,
          present INTEGER DEFAULT 1,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (student_id) REFERENCES $tableStudents($colId) ON DELETE CASCADE
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Criar tabela de escolas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableSchools (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Criar tabela de turmas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableClasses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          school_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          period TEXT,
          discipline TEXT,
          professor TEXT,
          shift TEXT,
          code TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (school_id) REFERENCES $tableSchools(id) ON DELETE CASCADE
        )
      ''');

      // Migrar dados existentes
      // Inserir escolas a partir dos estudantes existentes
      final distinctSchools = await db.rawQuery(
        'SELECT DISTINCT school FROM $tableStudents WHERE school IS NOT NULL'
      );
      
      for (var school in distinctSchools) {
        final schoolName = school['school'] as String?;
        if (schoolName != null && schoolName.isNotEmpty) {
          await db.insert(
            tableSchools,
            {'name': schoolName},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      // Inserir turmas a partir dos estudantes existentes
      final distinctClasses = await db.rawQuery(
        'SELECT DISTINCT school, class FROM $tableStudents WHERE school IS NOT NULL AND class IS NOT NULL'
      );
      
      for (var classRecord in distinctClasses) {
        final schoolName = classRecord['school'] as String?;
        final className = classRecord['class'] as String?;
        
        if (schoolName != null && className != null) {
          final schoolId = await db.rawQuery(
            'SELECT id FROM $tableSchools WHERE name = ?',
            [schoolName]
          );
          
          if (schoolId.isNotEmpty) {
            await db.insert(
              tableClasses,
              {
                'school_id': schoolId.first['id'],
                'name': className,
                'period': 'L 3º TRIMESTRE',
                'discipline': 'MATEMÁTICA',
                'professor': 'MANOEL DE MOURA',
                'shift': 'INTEGRAL',
                'code': className,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }
    }

    if (oldVersion < 4) {
      // Adicionar coluna class_id à tabela students
      try {
        await db.execute('ALTER TABLE $tableStudents ADD COLUMN class_id INTEGER');
      } catch (e) {
        // Coluna já existe, ignorar
      }

      // Popular class_id baseado nos dados antigos de school e class
      final students = await db.rawQuery('SELECT * FROM $tableStudents');
      
      for (var student in students) {
        final school = student['school'] as String?;
        final className = student['class'] as String?;
        
        if (school != null && className != null && school.isNotEmpty && className.isNotEmpty) {
          // Encontrar a turma correspondente
          final classResult = await db.rawQuery('''
            SELECT c.id FROM $tableClasses c
            JOIN $tableSchools s ON c.school_id = s.id
            WHERE s.name = ? AND c.name = ?
          ''', [school, className]);
          
          if (classResult.isNotEmpty) {
            final classId = classResult.first['id'] as int;
            await db.update(
              tableStudents,
              {'class_id': classId},
              where: '$colId = ?',
              whereArgs: [student[colId]],
            );
          }
        }
      }
    }

    if (oldVersion < 5) {
      // Adicionar coluna planned_lessons à tabela classes
      try {
        await db.execute('ALTER TABLE $tableClasses ADD COLUMN planned_lessons INTEGER DEFAULT 0');
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }

    if (oldVersion < 6) {
      // Adicionar coluna academic_period à tabela classes
      try {
        await db.execute('ALTER TABLE $tableClasses ADD COLUMN academic_period TEXT DEFAULT "1º Trimestre"');
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }

    if (oldVersion < 7) {
      // Criar tabela de conteúdo de aulas
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableLessonContent (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (class_id) REFERENCES $tableClasses(id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        // Tabela já existe, ignorar
      }
    }

    if (oldVersion < 8) {
      // Adicionar coluna grade_type à tabela grades
      try {
        await db.execute('ALTER TABLE $tableGrades ADD COLUMN grade_type TEXT DEFAULT "Prova"');
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }

    if (oldVersion < 9) {
      // Adicionar coluna evaluation_type à tabela students
      try {
        await db.execute('ALTER TABLE $tableStudents ADD COLUMN evaluation_type TEXT DEFAULT "Nota"');
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }

    if (oldVersion < 10) {
      try {
        await db.execute(
          'ALTER TABLE $tableLessonContent ADD COLUMN lessons_count INTEGER DEFAULT 1',
        );
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }

    if (oldVersion < 11) {
      // Adicionar coluna year à tabela classes
      try {
        await db.execute(
          'ALTER TABLE $tableClasses ADD COLUMN year INTEGER DEFAULT ${DateTime.now().year}',
        );
      } catch (e) {
        // Coluna já existe, ignorar
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    // Criar tabela de escolas
    await db.execute('''
      CREATE TABLE $tableSchools (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Criar tabela de turmas
    await db.execute('''
      CREATE TABLE $tableClasses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        period TEXT,
        discipline TEXT,
        professor TEXT,
        shift TEXT,
        code TEXT,
        year INTEGER DEFAULT ${DateTime.now().year},
        planned_lessons INTEGER DEFAULT 0,
        academic_period TEXT DEFAULT "1º Trimestre",
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES $tableSchools(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStudents (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT NOT NULL,
        $colRegNum TEXT UNIQUE,
        $colSchool TEXT,
        $colClass TEXT,
        class_id INTEGER,
        $colPhoto TEXT,
        evaluation_type TEXT DEFAULT "Nota",
        $colCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        $colUpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (class_id) REFERENCES $tableClasses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableGrades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        subject TEXT NOT NULL,
        grade REAL NOT NULL,
        max_grade REAL DEFAULT 10,
        date TEXT,
        grade_type TEXT DEFAULT 'Prova',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES $tableStudents($colId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableObservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        observation TEXT,
        date TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES $tableStudents($colId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAttendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        school TEXT,
        class TEXT,
        date TEXT NOT NULL,
        present INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES $tableStudents($colId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLessonContent (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        lessons_count INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (class_id) REFERENCES $tableClasses(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> addStudent(String name, String? regNum, String? school, String? classname, String? photoPath, {String evaluationType = 'Nota'}) async {
    Database db = await database;
    return await db.insert(tableStudents, {
      colName: name,
      colRegNum: regNum,
      colSchool: school != null ? _normalizeName(school) : null,
      colClass: classname != null ? _normalizeName(classname) : null,
      colPhoto: photoPath,
      'evaluation_type': evaluationType,
    });
  }

  Future<int> addStudentWithClass(String name, String? regNum, int classId, String? photoPath, {String evaluationType = 'Nota'}) async {
    Database db = await database;
    return await db.insert(tableStudents, {
      colName: name,
      colRegNum: regNum,
      'class_id': classId,
      colPhoto: photoPath,
      'evaluation_type': evaluationType,
    });
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    Database db = await database;
    // Query com JOIN para trazer dados da turma e escola
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.name,
        s.registration_number,
        s.photo_path,
        s.school,
        s.class,
        s.class_id,
        s.evaluation_type,
        COALESCE(c.name, s.class) as class_name,
        COALESCE(sch.name, s.school) as school_name,
        s.created_at,
        s.updated_at
      FROM $tableStudents s
      LEFT JOIN $tableClasses c ON s.class_id = c.id
      LEFT JOIN $tableSchools sch ON c.school_id = sch.id
      ORDER BY sch.name, c.name, s.name
    ''');
  }

  Future<List<Map<String, dynamic>>> getStudentsByClassId(int classId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.name,
        s.registration_number,
        s.photo_path,
        s.school,
        s.class,
        s.class_id,
        s.evaluation_type,
        COALESCE(c.name, s.class) as class_name,
        COALESCE(sch.name, s.school) as school_name,
        s.created_at,
        s.updated_at
      FROM $tableStudents s
      LEFT JOIN $tableClasses c ON s.class_id = c.id
      LEFT JOIN $tableSchools sch ON c.school_id = sch.id
      WHERE s.class_id = ?
      ORDER BY s.name
    ''', [classId]);
  }

  Future<Map<String, dynamic>?> getStudentById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableStudents, where: '$colId = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStudent(int id, String name, String? regNum, String? school, String? classname, String? photoPath, {String? evaluationType}) async {
    Database db = await database;
    final updateData = {
      colName: name,
      colRegNum: regNum,
      colSchool: school != null ? _normalizeName(school) : null,
      colClass: classname != null ? _normalizeName(classname) : null,
      colPhoto: photoPath,
      colUpdatedAt: DateTime.now().toIso8601String(),
    };
    
    if (evaluationType != null) {
      updateData['evaluation_type'] = evaluationType;
    }
    
    return await db.update(tableStudents, updateData, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete(tableStudents, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteStudentsBySchool(String school) async {
    Database db = await database;
    return await db.delete(tableStudents, where: '$colSchool = ?', whereArgs: [school]);
  }

  Future<int> deleteStudentsBySchoolAndClass(String school, String className) async {
    Database db = await database;
    return await db.delete(
      tableStudents,
      where: '$colSchool = ? AND $colClass = ?',
      whereArgs: [school, className],
    );
  }

  Future<double> getStudentTotal(int studentId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(grade) as total FROM $tableGrades WHERE student_id = ?',
      [studentId],
    );
    return result.isNotEmpty && result[0]['total'] != null ? (result[0]['total'] as num).toDouble() : 0.0;
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(int studentId) async {
    Database db = await database;
    return await db.query('grades', where: 'student_id = ?', whereArgs: [studentId], orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getStudentObservations(int studentId) async {
    Database db = await database;
    return await db.query('observations', where: 'student_id = ?', whereArgs: [studentId], orderBy: 'date DESC');
  }

  Future<int> addGrade(int studentId, String subject, double grade, double maxGrade, String date, {String gradeType = 'Prova'}) async {
    Database db = await database;
    return await db.insert('grades', {
      'student_id': studentId,
      'subject': subject,
      'grade': grade,
      'max_grade': maxGrade,
      'date': date,
      'grade_type': gradeType,
    });
  }

  Future<int> addObservation(int studentId, String observation, String date) async {
    Database db = await database;
    return await db.insert('observations', {
      'student_id': studentId,
      'observation': observation,
      'date': date,
    });
  }

  // Attendance methods
  Future<List<String>> getDistinctSchools() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT $colSchool FROM $tableStudents WHERE $colSchool IS NOT NULL ORDER BY $colSchool'
    );
    return result.map((e) => e['school'] as String).toList();
  }

  Future<List<String>> getClassesBySchool(String school) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT $colClass FROM $tableStudents WHERE $colSchool = ? AND $colClass IS NOT NULL ORDER BY $colClass',
      [school]
    );
    return result.map((e) => e['class'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getStudentsBySchoolAndClass(String school, String className) async {
    Database db = await database;
    // Buscar alunos antigos (com campos school/class como texto)
    // E também alunos novos (com class_id via JOIN)
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.name,
        s.registration_number,
        s.photo_path,
        s.school,
        s.class,
        s.class_id,
        COALESCE(c.name, s.class) as class_name,
        COALESCE(sch.name, s.school) as school_name,
        s.created_at,
        s.updated_at
      FROM $tableStudents s
      LEFT JOIN $tableClasses c ON s.class_id = c.id
      LEFT JOIN $tableSchools sch ON c.school_id = sch.id
      WHERE 
        (s.school = ? AND s.class = ?) OR
        (sch.name = ? AND c.name = ?)
      ORDER BY s.name
    ''', [school, className, school, className]);
  }

  Future<List<Map<String, dynamic>>> getStudentsByClass(int classId) async {
    Database db = await database;
    return await db.query(
      tableStudents,
      where: 'class_id = ?',
      whereArgs: [classId],
      orderBy: colName,
    );
  }

  Future<int> addAttendance(int studentId, String school, String className, String date, bool present) async {
    Database db = await database;
    print('DatabaseHelper.addAttendance - Insert: studentId=$studentId, school=$school, class=$className, date=$date, present=${present ? 1 : 0}');
    final id = await db.insert(tableAttendance, {
      'student_id': studentId,
      'school': school,
      'class': className,
      'date': date,
      'present': present ? 1 : 0,
    });
    print('Attendance record inserted with id: $id');
    return id;
  }

  Future<List<Map<String, dynamic>>> getAttendanceByClassAndDate(String school, String className, String date) async {
    Database db = await database;
    print('DatabaseHelper.getAttendanceByClassAndDate - school=$school, class=$className, date=$date');
    final results = await db.query(
      tableAttendance,
      where: 'school = ? AND class = ? AND date = ?',
      whereArgs: [school, className, date],
    );
    print('Found ${results.length} attendance records');
    return results;
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory(int studentId) async {
    Database db = await database;
    print('DatabaseHelper.getAttendanceHistory - studentId=$studentId');
    final results = await db.query(
      tableAttendance,
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    print('Found ${results.length} attendance records for student $studentId');
    return results;
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(int studentId) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date',
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceBySchoolAndClass(String school, String className) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'school = ? AND class = ?',
      whereArgs: [school, className],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteAttendanceRecord(int attendanceId) async {
    Database db = await database;
    return await db.delete(tableAttendance, where: 'id = ?', whereArgs: [attendanceId]);
  }

  Future<int> deleteGrade(int gradeId) async {
    Database db = await database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [gradeId]);
  }

  Future<List<Map<String, dynamic>>> getGradesByClassId(int classId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT g.*, s.name as student_name, s.registration_number
      FROM $tableGrades g
      INNER JOIN $tableStudents s ON g.student_id = s.id
      WHERE s.class_id = ?
      ORDER BY g.date DESC, s.name ASC
    ''', [classId]);
  }

  Future<List<Map<String, dynamic>>> getGradesByStudentId(int studentId) async {
    Database db = await database;
    return await db.query(
      tableGrades,
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
  }

  Future<int> updateGrade(int gradeId, double grade, String gradeType) async {
    Database db = await database;
    return await db.update(
      tableGrades,
      {'grade': grade, 'grade_type': gradeType},
      where: 'id = ?',
      whereArgs: [gradeId],
    );
  }

  Future<int> deleteObservation(int obsId) async {
    Database db = await database;
    return await db.delete('observations', where: 'id = ?', whereArgs: [obsId]);
  }

  // School management methods
  Future<int> addSchool(String name) async {
    Database db = await database;
    return await db.insert(tableSchools, {'name': _normalizeName(name)});
  }

  Future<List<Map<String, dynamic>>> getAllSchools() async {
    Database db = await database;
    return await db.query(tableSchools, orderBy: 'name');
  }

  Future<Map<String, dynamic>?> getSchoolById(int schoolId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableSchools, where: 'id = ?', whereArgs: [schoolId]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteSchool(int schoolId) async {
    Database db = await database;
    return await db.delete(tableSchools, where: 'id = ?', whereArgs: [schoolId]);
  }

  // Class management methods
  Future<int> addClass(int schoolId, String name, String? period, String? discipline, String? professor, String? shift, String? code, int? plannedLessons, String? academicPeriod, int? year) async {
    Database db = await database;
    return await db.insert(tableClasses, {
      'school_id': schoolId,
      'name': _normalizeName(name),
      'period': period,
      'discipline': discipline,
      'professor': professor,
      'shift': shift,
      'code': code,
      'planned_lessons': plannedLessons ?? 0,
      'academic_period': academicPeriod ?? '1º Trimestre',
      'year': year ?? DateTime.now().year,
    });
  }

  Future<List<Map<String, dynamic>>> getClassesBySchoolId(int schoolId) async {
    Database db = await database;
    return await db.query(tableClasses, where: 'school_id = ?', whereArgs: [schoolId], orderBy: 'name');
  }

  Future<Map<String, dynamic>?> getClassById(int classId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableClasses, where: 'id = ?', whereArgs: [classId]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateClass(int classId, int schoolId, String name, String? period, String? discipline, String? professor, String? shift, String? code, int? plannedLessons, String? academicPeriod, int? year) async {
    Database db = await database;
    return await db.update(tableClasses, {
      'school_id': schoolId,
      'name': _normalizeName(name),
      'period': period,
      'discipline': discipline,
      'professor': professor,
      'shift': shift,
      'code': code,
      'planned_lessons': plannedLessons ?? 0,
      'academic_period': academicPeriod ?? '1º Trimestre',
      'year': year ?? DateTime.now().year,
    }, where: 'id = ?', whereArgs: [classId]);
  }

  Future<int> deleteClass(int classId) async {
    Database db = await database;
    return await db.delete(tableClasses, where: 'id = ?', whereArgs: [classId]);
  }

  // Lesson Content CRUD
  Future<int> addLessonContent(int classId, String date, String content, {int lessonsCount = 1}) async {
    Database db = await database;
    return await db.insert(tableLessonContent, {
      'class_id': classId,
      'date': date,
      'content': content,
      'lessons_count': lessonsCount,
    });
  }

  Future<int> upsertLessonContent(int classId, String date, String content, {int lessonsCount = 1}) async {
    Database db = await database;
    final existing = await db.query(
      tableLessonContent,
      where: 'class_id = ? AND date = ?',
      whereArgs: [classId, date],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      return await db.update(
        tableLessonContent,
        {
          'content': content,
          'lessons_count': lessonsCount,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    return await addLessonContent(classId, date, content, lessonsCount: lessonsCount);
  }

  Future<List<Map<String, dynamic>>> getLessonContentByClassId(int classId) async {
    Database db = await database;
    return await db.query(
      tableLessonContent,
      where: 'class_id = ?',
      whereArgs: [classId],
      orderBy: 'date ASC',
    );
  }

  Future<int> updateLessonContent(int id, String date, String content, {int? lessonsCount}) async {
    Database db = await database;
    final updateData = <String, Object?>{'date': date, 'content': content};
    if (lessonsCount != null) {
      updateData['lessons_count'] = lessonsCount;
    }
    return await db.update(
      tableLessonContent,
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLessonContent(int id) async {
    Database db = await database;
    return await db.delete(tableLessonContent, where: 'id = ?', whereArgs: [id]);
  }

  // Busca o class_id pelo nome da escola e turma
  Future<int?> getClassIdByNames(String schoolName, String className) async {
    Database db = await database;
    
    // Primeiro busca o school_id
    var schoolResult = await db.query(
      tableSchools,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [schoolName],
      limit: 1,
    );
    
    if (schoolResult.isEmpty) return null;
    
    final schoolId = schoolResult.first['id'] as int;
    
    // Depois busca a turma
    var classResult = await db.query(
      tableClasses,
      columns: ['id'],
      where: 'school_id = ? AND name = ?',
      whereArgs: [schoolId, className],
      limit: 1,
    );
    
    if (classResult.isEmpty) return null;
    
    return classResult.first['id'] as int;
  }

  String _normalizeName(String name) {
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
}
