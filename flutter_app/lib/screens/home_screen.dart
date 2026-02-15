import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Caderneta de Notas'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => context.read<StudentProvider>().setSearchTerm(value),
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, matrícula, escola ou turma...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Lista de alunos
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
                        const Text(
                          'Nenhum aluno cadastrado',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Agrupar por escola e turma
                final groupedStudents = _groupStudents(provider.students);

                return ListView.builder(
                  itemCount: groupedStudents.length,
                  itemBuilder: (context, index) {
                    final school = groupedStudents[index]['school'];
                    final classes = groupedStudents[index]['classes'];

                    return ExpansionTile(
                      title: Text(
                        '🏫 $school',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      children: [
                        ...classes.asMap().entries.map((entry) {
                          final className = entry.value['class'];
                          final students = entry.value['students'];

                          return ExpansionTile(
                            title: Text(
                              '📖 $className',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            children: [
                              ...students.map<Widget>((student) {
                                return ListTile(
                                  title: Text(student['name']),
                                  subtitle: Text('Matrícula: ${student['registration_number'] ?? 'N/A'}'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentDetailScreen(studentId: student['id']),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  },
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

  List<Map<String, dynamic>> _groupStudents(List<Map<String, dynamic>> students) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (final student in students) {
      final school = student['school'] ?? 'Sem Escola';
      final className = student['class'] ?? 'Sem Turma';

      grouped.putIfAbsent(school, () => {});
      grouped[school]!.putIfAbsent(className, () => []);
      grouped[school]![className]!.add(student);
    }

    return grouped.entries.map((entry) {
      return {
        'school': entry.key,
        'classes': entry.value.entries
            .map((classEntry) => {
                  'class': classEntry.key,
                  'students': classEntry.value,
                })
            .toList(),
      };
    }).toList();
  }
}
