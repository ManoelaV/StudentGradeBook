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

                return ListView(
                  children: provider.students.map((student) {
                    return ListTile(
                      title: Text(student['name'] ?? ''),
                      subtitle: Text(student['school'] ?? 'Sem escola'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailScreen(studentId: student['id']),
                          ),
                        ).then((_) => context.read<StudentProvider>().loadStudents());
                      },
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
