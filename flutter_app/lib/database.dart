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

  // Colunas Students
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colRegNum = 'registration_number';
  static const String colSchool = 'school';
  static const String colClass = 'class';
  static const String colPhoto = 'photo_path';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Colunas Grades
  static const String colGradeId = 'id';
  static const String colStudentId = 'student_id';
  static const String colSubject = 'subject';
  static const String colGrade = 'grade';
  static const String colMaxGrade = 'max_grade';
  static const String colDate = 'date';

  // Colunas Observations
  static const String colObsId = 'id';
  static const String colObsStudentId = 'student_id';
  static const String colObservation = 'observation';
  static const String colObsDate = 'date';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
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
        $colGradeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colStudentId INTEGER NOT NULL,
        $colSubject TEXT NOT NULL,
        $colGrade REAL NOT NULL,
        $colMaxGrade REAL DEFAULT 10,
        $colDate TEXT,
        $colCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY ($colStudentId) REFERENCES $tableStudents($colId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableObservations (
        $colObsId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colObsStudentId INTEGER NOT NULL,
        $colObservation TEXT,
        $colObsDate TEXT,
        $colCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY ($colObsStudentId) REFERENCES $tableStudents($colId) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD Students
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
    List<Map<String, dynamic>> results = await db.query(
      tableStudents,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStudent(int id, String name, String? regNum, String? school, String? classname, String? photoPath) async {
    Database db = await database;
    return await db.update(
      tableStudents,
      {
        colName: name,
        colRegNum: regNum,
        colSchool: school != null ? _normalizeName(school) : null,
        colClass: classname != null ? _normalizeName(classname) : null,
        colPhoto: photoPath,
        colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete(
      tableStudents,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // CRUD Grades
  Future<int> addGrade(int studentId, String subject, double grade, double maxGrade, String date) async {
    Database db = await database;
    return await db.insert(tableGrades, {
      colStudentId: studentId,
      colSubject: subject,
      colGrade: grade,
      colMaxGrade: maxGrade,
      colDate: date,
    });
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(int studentId) async {
    Database db = await database;
    return await db.query(
      tableGrades,
      where: '$colStudentId = ?',
      whereArgs: [studentId],
      orderBy: '$colDate DESC',
    );
  }

  Future<double> getStudentTotal(int studentId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM($colGrade) as total FROM $tableGrades WHERE $colStudentId = ?',
      [studentId],
    );
    return result.isNotEmpty && result[0]['total'] != null ? (result[0]['total'] as num).toDouble() : 0.0;
  }

  Future<int> deleteGrade(int gradeId) async {
    Database db = await database;
    return await db.delete(
      tableGrades,
      where: '$colGradeId = ?',
      whereArgs: [gradeId],
    );
  }

  // CRUD Observations
  Future<int> addObservation(int studentId, String observation, String date) async {
    Database db = await database;
    return await db.insert(tableObservations, {
      colObsStudentId: studentId,
      colObservation: observation,
      colObsDate: date,
    });
  }

  Future<List<Map<String, dynamic>>> getStudentObservations(int studentId) async {
    Database db = await database;
    return await db.query(
      tableObservations,
      where: '$colObsStudentId = ?',
      whereArgs: [studentId],
      orderBy: '$colObsDate DESC',
    );
  }

  Future<int> deleteObservation(int obsId) async {
    Database db = await database;
    return await db.delete(
      tableObservations,
      where: '$colObsId = ?',
      whereArgs: [obsId],
    );
  }

  // Normalizar nomes (TitleCase)
  String _normalizeName(String name) {
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
}
