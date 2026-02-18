import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedSchool;
  String? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  final Map<int, bool> _attendance = {};
  final TextEditingController _lessonContentController = TextEditingController();
  final TextEditingController _lessonsCountController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper();

  @override
  void dispose() {
    _lessonContentController.dispose();
    _lessonsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    String? getSchoolName(Map<String, dynamic> student) {
      return (student['school_name'] ?? student['school']) as String?;
    }

    String? getClassName(Map<String, dynamic> student) {
      return (student['class_name'] ?? student['class']) as String?;
    }
    
    // Obter lista de escolas e turmas
    final allStudents = studentProvider.students;
    final schools = allStudents
      .map(getSchoolName)
        .where((s) => s != null && s.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();
    schools.sort();
    
    List<String> classes = [];
    if (_selectedSchool != null) {
      classes = allStudents
          .where((s) => getSchoolName(s) == _selectedSchool)
          .map(getClassName)
          .where((c) => c != null && c.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
      classes.sort();
    }

    final studentsInClass = (_selectedSchool != null && _selectedClass != null)
        ? allStudents
            .where(
              (s) =>
                  getSchoolName(s) == _selectedSchool &&
                  getClassName(s) == _selectedClass,
            )
            .toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Chamada'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSchool,
                        decoration: const InputDecoration(
                          labelText: 'Escola',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: schools.map((school) {
                          return DropdownMenuItem(
                            value: school,
                            child: Text(school),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSchool = value;
                            _selectedClass = null;
                            _attendance.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Turma',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: classes.map((className) {
                          return DropdownMenuItem(
                            value: className,
                            child: Text(className),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                            _attendance.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _lessonContentController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Conteudo da aula',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lessonsCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Aulas do dia',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de alunos
          Expanded(
            child: studentsInClass.isEmpty
                ? const Center(
                    child: Text(
                      'Selecione uma escola e turma',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: studentsInClass.length,
                    itemBuilder: (context, index) {
                      final student = studentsInClass[index];
                      final studentId = student['id'] as int;
                      final isPresent = _attendance[studentId] ?? true;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: CheckboxListTile(
                          title: Text(student['name'] ?? 'Sem nome'),
                          subtitle: student['registration_number'] != null
                              ? Text('Matrícula: ${student['registration_number']}')
                              : null,
                          value: isPresent,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              _attendance[studentId] = value ?? true;
                            });
                          },
                          secondary: CircleAvatar(
                            backgroundColor: isPresent ? Colors.green : Colors.red,
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Botão salvar
          if (studentsInClass.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_selectedSchool == null || _selectedClass == null) return;
                  
                  try {
                    final dateStr =
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

                    final lessonContent = _lessonContentController.text.trim();
                    final lessonsCount = int.tryParse(_lessonsCountController.text.trim()) ?? 1;
                    if (lessonContent.isNotEmpty || lessonsCount > 0) {
                      final classId = await _db.getClassIdByNames(
                        _selectedSchool!,
                        _selectedClass!,
                      );
                      if (classId != null) {
                        await _db.upsertLessonContent(
                          classId,
                          dateStr,
                          lessonContent,
                          lessonsCount: lessonsCount,
                        );
                      }
                    }
                    
                    // Registrar chamada para cada aluno
                    for (var student in studentsInClass) {
                      final studentId = student['id'] as int;
                      final isPresent = _attendance[studentId] ?? true;
                      
                      print('Registrando chamada - Aluno ID: $studentId, Data: $dateStr, Presente: $isPresent');
                      
                      await attendanceProvider.addAttendance(
                        studentId,
                        _selectedSchool!,
                        _selectedClass!,
                        dateStr,
                        isPresent,
                      );
                    }
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Chamada registrada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Limpar seleção ao salvar
                      setState(() {
                        _attendance.clear();
                        _lessonContentController.clear();
                        _lessonsCountController.clear();
                      });
                    }
                  } catch (e) {
                    print('Erro ao registrar chamada: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Erro ao registrar chamada: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar Chamada'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
