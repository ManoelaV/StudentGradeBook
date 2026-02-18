import 'package:flutter/material.dart';
import '../database.dart';

class AttendanceProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _attendanceRecords = [];
  String? _selectedSchool;
  String? _selectedClass;
  String? _selectedDate;

  List<Map<String, dynamic>> get attendanceRecords => _attendanceRecords;
  String? get selectedSchool => _selectedSchool;
  String? get selectedClass => _selectedClass;
  String? get selectedDate => _selectedDate;

  void setSelectedSchool(String? school) {
    _selectedSchool = school;
    notifyListeners();
  }

  void setSelectedClass(String? className) {
    _selectedClass = className;
    notifyListeners();
  }

  void setSelectedDate(String? date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadAttendanceByClassAndDate(String school, String className, String date) async {
    _attendanceRecords = await _db.getAttendanceByClassAndDate(school, className, date);
    notifyListeners();
  }

  Future<void> loadAttendanceBySchoolAndClass(String school, String className) async {
    _attendanceRecords = await _db.getAttendanceBySchoolAndClass(school, className);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory(int studentId) async {
    print('AttendanceProvider.getAttendanceHistory - studentId: $studentId');
    try {
      final history = await _db.getAttendanceHistory(studentId);
      print('Found ${history.length} attendance records for student $studentId');
      return history;
    } catch (e) {
      print('Error in getAttendanceHistory: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(int studentId) async {
    return await _db.getStudentAttendance(studentId);
  }

  Future<void> addAttendance(int studentId, String school, String className, String date, bool present) async {
    print('AttendanceProvider.addAttendance - studentId: $studentId, school: $school, class: $className, date: $date, present: $present');
    try {
      await _db.addAttendance(studentId, school, className, date, present);
      await loadAttendanceByClassAndDate(school, className, date);
      print('Attendance added successfully');
    } catch (e) {
      print('Error in addAttendance: $e');
      rethrow;
    }
  }

  Future<void> deleteAttendanceRecord(int attendanceId) async {
    await _db.deleteAttendanceRecord(attendanceId);
    notifyListeners();
  }

  Future<Map<String, int>> getAttendanceStats(int studentId) async {
    final records = await _db.getStudentAttendance(studentId);
    int totalDays = records.length;
    int presentDays = records.where((r) => r['present'] == 1).length;
    int absentDays = totalDays - presentDays;
    
    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
    };
  }

  double getAttendancePercentage(int presentDays, int totalDays) {
    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }
}
