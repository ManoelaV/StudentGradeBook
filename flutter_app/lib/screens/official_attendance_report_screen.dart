import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../database.dart';
import '../utils/pdf_generator.dart';

class OfficialAttendanceReportScreen extends StatefulWidget {
  const OfficialAttendanceReportScreen({super.key});

  @override
  State<OfficialAttendanceReportScreen> createState() =>
      _OfficialAttendanceReportScreenState();
}

class _OfficialAttendanceReportScreenState
    extends State<OfficialAttendanceReportScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  int? _selectedSchoolId;
  int? _selectedClassId;
  Map<String, dynamic>? _classInfo;
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _classes = [];
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Inicializar datas para o mês atual
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1); // Primeiro dia do mês
    _endDate = DateTime(now.year, now.month, now.day); // Hoje
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    final schools = await _db.getAllSchools();
    setState(() {
      _schools = schools;
    });
  }

  Future<void> _loadClasses(int schoolId) async {
    final classes = await _db.getClassesBySchoolId(schoolId);
    setState(() {
      _classes = classes;
      _selectedClassId = null;
      _classInfo = null;
    });
  }

  Future<void> _loadClassInfo(int classId) async {
    final classInfo = await _db.getClassById(classId);
    setState(() {
      _classInfo = classInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Chamada (Formato Oficial)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecione a Escola',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedSchoolId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Selecione uma escola'),
              items: _schools.map((school) {
                return DropdownMenuItem<int>(
                  value: school['id'],
                  child: Text(school['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSchoolId = value;
                  _selectedClassId = null;
                  _classInfo = null;
                });
                if (value != null) {
                  _loadClasses(value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecione a Turma',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedClassId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Selecione uma turma'),
              items: _classes.map((classItem) {
                return DropdownMenuItem<int>(
                  value: classItem['id'],
                  child: Text(classItem['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
                if (value != null) {
                  _loadClassInfo(value);
                }
              },
            ),
            const SizedBox(height: 24),
            if (_classInfo != null) ...[
              const Text(
                'Periodo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: _endDate,
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Inicio: ${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Fim: ${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações da Turma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_classInfo!['discipline'] != null)
                      _buildInfoRow('Disciplina:', _classInfo!['discipline']),
                    if (_classInfo!['professor'] != null)
                      _buildInfoRow('Professor:', _classInfo!['professor']),
                    if (_classInfo!['academic_period'] != null)
                      _buildInfoRow('Período Letivo:', _classInfo!['academic_period']),
                    if (_classInfo!['shift'] != null)
                      _buildInfoRow('Turno:', _classInfo!['shift']),
                    if (_classInfo!['code'] != null)
                      _buildInfoRow('Código:', _classInfo!['code']),
                    if (_classInfo!['planned_lessons'] != null)
                      _buildInfoRow('Aulas Previstas:', _classInfo!['planned_lessons'].toString()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGenerating
                      ? null
                      : () async {
                          setState(() => _isGenerating = true);
                          try {
                            final school = _schools.firstWhere(
                              (s) => s['id'] == _selectedSchoolId,
                              orElse: () => {},
                            );
                            final schoolName = school['name']?.toString() ?? '';
                            final className = _classInfo?['name']?.toString() ?? '';

                            final attendanceRecords = await _db.getAttendanceBySchoolAndClass(
                              schoolName,
                              className,
                            );

                            final filteredAttendance = attendanceRecords.where((record) {
                              final dateStr = record['date'] as String?;
                              if (dateStr == null) return false;
                              final date = DateTime.tryParse(dateStr);
                              if (date == null) return false;
                              final day = DateTime(date.year, date.month, date.day);
                              final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
                              final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
                              return !day.isBefore(start) && !day.isAfter(end);
                            }).toList();

                            final lessonContent = await _db.getLessonContentByClassId(_selectedClassId!);
                            final lessonsByDate = <String, int>{};
                            for (final item in lessonContent) {
                              final dateStr = item['date']?.toString();
                              if (dateStr == null) continue;
                              final date = DateTime.tryParse(dateStr);
                              if (date == null) continue;
                              final day = DateTime(date.year, date.month, date.day);
                              final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
                              final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
                              if (day.isBefore(start) || day.isAfter(end)) continue;
                              final count = item['lessons_count'] as int? ?? 1;
                              lessonsByDate[dateStr] = count;
                            }

                            var students = await _db.getStudentsByClassId(_selectedClassId!);
                            if (students.isEmpty) {
                              final allStudents = await _db.getAllStudents();
                              students = allStudents.where((s) {
                                return s['class_name'] == className && s['school_name'] == schoolName;
                              }).toList();
                            }

                            final studentsWithTotals = <Map<String, dynamic>>[];
                            for (final student in students) {
                              final studentId = student['id'] as int?;
                              if (studentId == null) continue;
                              final total = await _db.getStudentTotal(studentId);
                              final rec = await _db.getStudentRecoveryGrade(studentId);
                              final finalGrade = await _db.getStudentFinalGrade(studentId);
                              studentsWithTotals.add({
                                ...student,
                                'total': total,
                                'rec': rec,
                                'final_grade': finalGrade,
                              });
                            }

                            final bytes = await PDFGenerator.generateOfficialAttendanceReportPDF(
                              schoolName: schoolName,
                              classInfo: _classInfo ?? {},
                              students: studentsWithTotals,
                              attendanceRecords: filteredAttendance,
                              lessonsByDate: lessonsByDate,
                              lessonContent: lessonContent,
                              startDate: _startDate,
                              endDate: _endDate,
                            );

                            final defaultName =
                                'relatorio_oficial_${schoolName}_${className}_${DateTime.now().millisecondsSinceEpoch}.pdf'
                                    .replaceAll(' ', '_');
                            final location = await getSaveLocation(
                              suggestedName: defaultName,
                              acceptedTypeGroups: const [
                                XTypeGroup(label: 'PDF', extensions: ['pdf']),
                              ],
                            );

                            if (location == null) {
                              return;
                            }

                            final file = File(location.path);
                            await file.writeAsBytes(bytes, flush: true);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ PDF gerado: ${file.path}'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Erro ao gerar PDF: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isGenerating = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Gerar Relatório',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
