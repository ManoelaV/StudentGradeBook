import 'package:flutter/material.dart';
import '../database.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _students = [];
  String _searchTerm = '';

  List<Map<String, dynamic>> get students => _getFilteredStudents();
  String get searchTerm => _searchTerm;

  Future<void> loadStudents() async {
    _students = await _db.getAllStudents();
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term.toLowerCase();
    notifyListeners();
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_searchTerm.isEmpty) return _students;
    return _students.where((student) {
      final name = (student['name'] as String?)?.toLowerCase() ?? '';
      final regNum = (student['registration_number'] as String?)?.toLowerCase() ?? '';
      final school = (student['school'] as String?)?.toLowerCase() ?? '';
      final classname = (student['class'] as String?)?.toLowerCase() ?? '';
      
      return name.contains(_searchTerm) ||
             regNum.contains(_searchTerm) ||
             school.contains(_searchTerm) ||
             classname.contains(_searchTerm);
    }).toList();
  }

  Future<void> addStudent(String name, String? regNum, String? school, String? classname, String? photoPath) async {
    await _db.addStudent(name, regNum, school, classname, photoPath);
    await loadStudents();
  }

  Future<void> updateStudent(int id, String name, String? regNum, String? school, String? classname, String? photoPath) async {
    await _db.updateStudent(id, name, regNum, school, classname, photoPath);
    await loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    await _db.deleteStudent(id);
    await loadStudents();
  }

  Future<double> getStudentTotal(int studentId) async {
    return await _db.getStudentTotal(studentId);
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(int studentId) async {
    return await _db.getStudentGrades(studentId);
  }

  Future<List<Map<String, dynamic>>> getStudentObservations(int studentId) async {
    return await _db.getStudentObservations(studentId);
  }

  Future<void> addGrade(int studentId, String subject, double grade, double maxGrade, String date) async {
    await _db.addGrade(studentId, subject, grade, maxGrade, date);
    notifyListeners();
  }

  Future<void> addObservation(int studentId, String observation, String date) async {
    await _db.addObservation(studentId, observation, date);
    notifyListeners();
  }

  Future<void> deleteGrade(int gradeId) async {
    await _db.deleteGrade(gradeId);
    notifyListeners();
  }

  Future<void> deleteObservation(int obsId) async {
    await _db.deleteObservation(obsId);
    notifyListeners();
  }
}
