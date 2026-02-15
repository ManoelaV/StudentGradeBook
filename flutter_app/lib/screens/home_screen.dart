import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/student_provider.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StudentProvider>().loadStudents());
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupStudents(
      List<Map<String, dynamic>> students) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var student in students) {
      final school = student['school'] ?? 'Sem escola';
      final grade = student['class'] ?? 'Sem turma';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Caderneta de Notas'),
        elevation: 0,
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: Colors.blue[700],
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                school,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...gradeMap.entries.map((gradeEntry) {
                          final grade = gradeEntry.key;
                          final students = gradeEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: Colors.blue[100],
                                child: Row(
                                  children: [
                                    const Icon(Icons.class_, size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      grade,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                  ],
                                ),
                              ),
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
                                      '${student['school'] ?? 'Sem escola'} - ${student['class'] ?? 'Sem turma'}',
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
                              }).toList(),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
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
