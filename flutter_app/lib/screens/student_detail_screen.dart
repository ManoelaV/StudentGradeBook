import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/student_provider.dart';
import 'add_student_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Future<Map<String, dynamic>> _studentFuture;
  late Future<double> _totalFuture;
  late Future<List<Map<String, dynamic>>> _gradesFuture;
  late Future<List<Map<String, dynamic>>> _observationsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = context.read<StudentProvider>();
    _totalFuture = provider.getStudentTotal(widget.studentId);
    _gradesFuture = provider.getStudentGrades(widget.studentId);
    _observationsFuture = provider.getStudentObservations(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aluno'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Editar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStudentScreen(studentId: widget.studentId),
                    ),
                  ).then((_) {
                    setState(() => _loadData());
                  });
                },
              ),
              PopupMenuItem(
                child: const Text('Adicionar Nota'),
                onTap: () => _showAddGradeDialog(),
              ),
              PopupMenuItem(
                child: const Text('Adicionar Observação'),
                onTap: () => _showAddObservationDialog(),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadStudent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Aluno não encontrado'));
          }

          final student = snapshot.data!;
          final name = student['name'] ?? 'Desconhecido';
          final school = student['school'] ?? 'Sem Escola';
          final className = student['class'] ?? 'Sem Turma';
          final photoPath = student['photo_path'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header com foto
                Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (photoPath != null && File(photoPath).existsSync())
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(File(photoPath)),
                        )
                      else
                        CircleAvatar(
                          radius: 50,
                          child: Text(name[0].toUpperCase()),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('$school - $className', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 16),
                      FutureBuilder<double>(
                        future: _totalFuture,
                        builder: (context, snapshot) {
                          final total = snapshot.data ?? 0.0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Total: ${total.toStringAsFixed(2)} pontos',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Notas
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _gradesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Sem notas cadastradas');
                          }

                          final grades = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: grades.length,
                            itemBuilder: (context, index) {
                              final grade = grades[index];
                              return ListTile(
                                title: Text(grade['subject'] ?? 'Sem disciplina'),
                                subtitle: Text('${grade['date'] ?? ''}'),
                                trailing: Text('${grade['grade']}/${grade['max_grade'] ?? 10}'),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Observações
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _observationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Sem observações cadastradas');
                          }

                          final observations = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: observations.length,
                            itemBuilder: (context, index) {
                              final obs = observations[index];
                              return Card(
                                child: ListTile(
                                  title: Text(obs['observation'] ?? ''),
                                  subtitle: Text(obs['date'] ?? ''),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadStudent() async {
    // Aqui você carregaria os dados do aluno do banco de dados
    // Por enquanto, retornaremos um mapa vazio
    return {};
  }

  void _showAddGradeDialog() {
    final subjectController = TextEditingController();
    final gradeController = TextEditingController();
    final maxGradeController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Disciplina')),
            const SizedBox(height: 8),
            TextField(controller: gradeController, decoration: const InputDecoration(labelText: 'Nota'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: maxGradeController, decoration: const InputDecoration(labelText: 'Nota Máxima'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<StudentProvider>().addGrade(
                widget.studentId,
                subjectController.text,
                double.parse(gradeController.text),
                double.parse(maxGradeController.text),
                DateTime.now().toIso8601String().split('T')[0],
              );
              Navigator.pop(context);
              setState(() => _loadData());
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddObservationDialog() {
    final obsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Observação'),
        content: TextField(
          controller: obsController,
          decoration: const InputDecoration(labelText: 'Observação'),
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<StudentProvider>().addObservation(
                widget.studentId,
                obsController.text,
                DateTime.now().toIso8601String().split('T')[0],
              );
              Navigator.pop(context);
              setState(() => _loadData());
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
