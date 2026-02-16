import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "student_gradebook.db";
  static const _databaseVersion = 1;

  static const String tableStudents = 'students';
  static const String tableGrades = 'grades';
  static const String tableObservations = 'observations';
  static const String tableAttendance = 'attendance';

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
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStudents (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT NOT NULL,
        $colRegNum TEXT UNIQUE,
        $colSchool TEXT,
        $colClass TEXT,
        $colPhoto TEXT,
        $colCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        $colUpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
  }

  Future<int> addStudent(String name, String? regNum, String? school, String? classname, String? photoPath) async {
    Database db = await database;
    return await db.insert(tableStudents, {
      colName: name,
      colRegNum: regNum,
      colSchool: school != null ? _normalizeName(school) : null,
      colClass: classname != null ? _normalizeName(classname) : null,
      colPhoto: photoPath,
    });
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    Database db = await database;
    return await db.query(tableStudents, orderBy: '$colSchool, $colClass, $colName');
  }

  Future<Map<String, dynamic>?> getStudentById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableStudents, where: '$colId = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStudent(int id, String name, String? regNum, String? school, String? classname, String? photoPath) async {
    Database db = await database;
    return await db.update(tableStudents, {
      colName: name,
      colRegNum: regNum,
      colSchool: school != null ? _normalizeName(school) : null,
      colClass: classname != null ? _normalizeName(classname) : null,
      colPhoto: photoPath,
      colUpdatedAt: DateTime.now().toIso8601String(),
    }, where: '$colId = ?', whereArgs: [id]);
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

  Future<int> addGrade(int studentId, String subject, double grade, double maxGrade, String date) async {
    Database db = await database;
    return await db.insert('grades', {
      'student_id': studentId,
      'subject': subject,
      'grade': grade,
      'max_grade': maxGrade,
      'date': date,
    });
  }

  Future<int> addObservation(int studentId, String observation, String date) async {
    Database db = await database;
    return await db.insert('observations', {
      'student_id': studentId,
      'observation': observation,
      'date': date,
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
    return await db.query(
      tableStudents,
      where: '$colSchool = ? AND $colClass = ?',
      whereArgs: [school, className],
      orderBy: colName,
    );
  }

  Future<int> addAttendance(int studentId, String school, String className, String date, bool present) async {
    Database db = await database;
    return await db.insert(tableAttendance, {
      'student_id': studentId,
      'school': school,
      'class': className,
      'date': date,
      'present': present ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAttendanceByClassAndDate(String school, String className, String date) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'school = ? AND class = ? AND date = ?',
      whereArgs: [school, className, date],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory(int studentId) async {
    Database db = await database;
    return await db.query(
      tableAttendance,
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteAttendanceRecord(int attendanceId) async {
    Database db = await database;
    return await db.delete(tableAttendance, where: 'id = ?', whereArgs: [attendanceId]);
  }

    });
  }

  Future<int> deleteGrade(int gradeId) async {
    Database db = await database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [gradeId]);
  }

  Future<int> deleteObservation(int obsId) async {
    Database db = await database;
    return await db.delete('observations', where: 'id = ?', whereArgs: [obsId]);
  }

  String _normalizeName(String name) {
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
}
