import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StudentProvider>().getStudentDetail(widget.studentId));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _addGrade() async {
    if (_subjectController.text.isEmpty || _gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      final grade = double.parse(_gradeController.text);
      await context.read<StudentProvider>().addGrade(
        studentId: widget.studentId,
        subject: _subjectController.text,
        grade: grade,
      );

      _subjectController.clear();
      _gradeController.clear();

      await context.read<StudentProvider>().getStudentDetail(widget.studentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota adicionada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar nota: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aluno'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final student = provider.currentStudent;

          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escola: ${student['school'] ?? ''}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Série: ${student['grade'] ?? ''}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adicionar Nota',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Disciplina',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.book),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _gradeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Nota (0-10)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.grade),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addGrade,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Nota'),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((student['grades'] as List?)?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(student['grades'] as List).map((gradeItem) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(gradeItem['subject'] ?? ''),
                              subtitle: Text('Nota: ${gradeItem['grade']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await context.read<StudentProvider>().deleteGrade(
                                      studentId: widget.studentId,
                                      gradeId: gradeItem['id'],
                                    );

                                    await context.read<StudentProvider>().getStudentDetail(widget.studentId);

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Nota removida!')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro ao remover nota: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.grade, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhuma nota cadastrada'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
