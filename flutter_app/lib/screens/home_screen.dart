import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/student_provider.dart';
import '../utils/pdf_generator.dart';
import '../database.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';
import 'pdf_import_screen.dart';
import 'backup_screen.dart';
import 'attendance_screen.dart';
import 'school_management_screen.dart';
import 'class_management_screen.dart';
import 'official_attendance_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _expandedSchools = {};
  final Map<String, Set<String>> _expandedGrades = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StudentProvider>().loadStudents());
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupStudents(
      List<Map<String, dynamic>> students) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var student in students) {
      // Usar school_name (do JOIN) com fallback para school (campo antigo)
      final school = student['school_name'] ?? student['school'] ?? 'Sem escola';
      // Usar class_name (do JOIN) com fallback para class (campo antigo)
      final grade = student['class_name'] ?? student['class'] ?? 'Sem turma';

      if (!grouped.containsKey(school)) {
        grouped[school] = {};
      }
      if (!grouped[school]!.containsKey(grade)) {
        grouped[school]![grade] = [];
      }
      grouped[school]![grade]!.add(student);
    }

    return grouped;
  }

  void _showDeleteStudentDialog(
    BuildContext context,
    Map<String, dynamic> student,
    StudentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir aluno?'),
        content: Text('Tem certeza que deseja excluir ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteStudent(student['id']);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ ${student['name']} removido')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteGradeDialog(
    BuildContext context,
    String school,
    String grade,
    int studentCount,
    StudentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir turma?'),
        content: Text(
          'Tem certeza que deseja excluir a turma $grade ($studentCount alunos)?'
          '\n\n⚠️ Todos os alunos serão removidos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final db = DatabaseHelper();
              await db.deleteStudentsBySchoolAndClass(school, grade);
              await provider.loadStudents();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Turma $grade removida')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSchoolDialog(
    BuildContext context,
    String school,
    StudentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir escola?'),
        content: Text(
          'Tem certeza que deseja excluir $school?'
          '\n\n⚠️ Todos os alunos e turmas serão removidos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final db = DatabaseHelper();
              await db.deleteStudentsBySchool(school);
              await provider.loadStudents();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Escola $school removida')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Caderneta de Notas'),
        elevation: 0,
        actions: [
          PopupMenuButton<void>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.school, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Gerenciar Escolas'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SchoolManagementScreen()),
                  );
                },
              ),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.class_, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Gerenciar Turmas'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClassManagementScreen()),
                  );
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.assignment_turned_in, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Chamada'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                  );
                },
              ),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Relatório Oficial (PDF)'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OfficialAttendanceReportScreen()),
                  );
                },
              ),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Importar Alunos (PDF)'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PDFImportScreen()),
                  ).then((_) => context.read<StudentProvider>().loadStudents());
                },
              ),
              PopupMenuItem<void>(
                child: const Row(
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Backup e Sincronização'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BackupScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => context.read<StudentProvider>().setSearchTerm(value),
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Nenhum aluno cadastrado'),
                      ],
                    ),
                  );
                }

                final groupedStudents = _groupStudents(provider.students);

                return ListView(
                  children: groupedStudents.entries.map((schoolEntry) {
                    final school = schoolEntry.key;
                    final gradeMap = schoolEntry.value;
                    final isSchoolExpanded = _expandedSchools.contains(school);

                    if (!_expandedGrades.containsKey(school)) {
                      _expandedGrades[school] = {};
                    }

                    return ExpansionTile(
                      initiallyExpanded: false,
                      title: Row(
                        children: [
                          const Icon(Icons.school, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            school,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${gradeMap.values.fold<int>(0, (sum, grades) => sum + grades.length)}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Excluir escola',
                            onPressed: () {
                              _showDeleteSchoolDialog(context, school, provider);
                            },
                          ),
                        ],
                      ),
                      backgroundColor: Colors.blue[50],
                      collapsedBackgroundColor: Colors.blue[700],
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.blue,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            _expandedSchools.add(school);
                          } else {
                            _expandedSchools.remove(school);
                          }
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: gradeMap.entries.map((gradeEntry) {
                              final grade = gradeEntry.key;
                              final students = gradeEntry.value;
                              final gradeKey = '${school}_$grade';
                              final isGradeExpanded = _expandedGrades[school]?.contains(grade) ?? false;

                              return ExpansionTile(
                                initiallyExpanded: false,
                                title: Row(
                                  children: [
                                    const Icon(Icons.class_, size: 18, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        grade,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${students.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      tooltip: 'Excluir turma',
                                      onPressed: () {
                                        _showDeleteGradeDialog(context, school, grade, students.length, provider);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.file_download, color: Colors.green, size: 20),
                                      tooltip: 'Exportar para PDF',
                                      onPressed: () async {
                                        try {
                                          await PDFGenerator.generateClassGradesPDF(
                                            school,
                                            grade,
                                            students,
                                            DatabaseHelper(),
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('✅ PDF gerado com sucesso!')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('❌ Erro ao gerar PDF: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.blue[100],
                                collapsedBackgroundColor: Colors.grey[100],
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    if (expanded) {
                                      _expandedGrades[school]?.add(grade);
                                    } else {
                                      _expandedGrades[school]?.remove(grade);
                                    }
                                  });
                                },
                                children: [
                                  ...students.map((student) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: student['photo_path'] != null
                                              ? FileImage(File(student['photo_path']))
                                              : null,
                                          child: student['photo_path'] == null
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        title: Text(student['name'] ?? ''),
                                        subtitle: Text(
                                          '${student['school_name'] ?? student['school'] ?? 'Sem escola'} - ${student['class_name'] ?? student['class'] ?? 'Sem turma'}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Excluir aluno',
                                          onPressed: () {
                                            _showDeleteStudentDialog(context, student, provider);
                                          },
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentDetailScreen(studentId: student['id'] as int),
                                            ),
                                          ).then((_) => context.read<StudentProvider>().loadStudents());
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          ).then((_) => context.read<StudentProvider>().loadStudents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
