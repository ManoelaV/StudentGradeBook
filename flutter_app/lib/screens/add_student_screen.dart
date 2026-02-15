import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../providers/student_provider.dart';

class AddStudentScreen extends StatefulWidget {
  final int? studentId;

  const AddStudentScreen({Key? key, this.studentId}) : super(key: key);

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _regNumController;
  late TextEditingController _schoolController;
  late TextEditingController _classController;
  String? _selectedPhoto;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _regNumController = TextEditingController();
    _schoolController = TextEditingController();
    _classController = TextEditingController();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    if (widget.studentId != null) {
      final provider = context.read<StudentProvider>();
      final students = await provider.getStudentGrades(widget.studentId!);
      // Carrega dados existentes
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(image.path);
        final String newPath = '${appDocDir.path}/photos/$fileName';
        
        // Criar pasta photos se não existir
        final Directory photosDir = Directory('${appDocDir.path}/photos');
        if (!photosDir.existsSync()) {
          photosDir.createSync(recursive: true);
        }

        final File newFile = File(image.path).copySync(newPath);
        setState(() => _selectedPhoto = newFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  void _clearPhoto() {
    setState(() => _selectedPhoto = null);
  }

  void _save() async {
    final name = _nameController.text.trim();
    final regNum = _regNumController.text.trim().isEmpty ? null : _regNumController.text.trim();
    final school = _schoolController.text.trim().isEmpty ? null : _schoolController.text.trim();
    final className = _classController.text.trim().isEmpty ? null : _classController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do aluno')),
      );
      return;
    }

    try {
      final provider = context.read<StudentProvider>();
      
      if (widget.studentId == null) {
        await provider.addStudent(name, regNum, school, className, _selectedPhoto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aluno cadastrado com sucesso!')),
          );
        }
      } else {
        await provider.updateStudent(widget.studentId!, name, regNum, school, className, _selectedPhoto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aluno atualizado com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId == null ? 'Novo Aluno' : 'Editar Aluno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Aluno',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Matrícula
            TextField(
              controller: _regNumController,
              decoration: InputDecoration(
                labelText: 'Matrícula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Escola
            TextField(
              controller: _schoolController,
              decoration: InputDecoration(
                labelText: 'Escola',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Turma
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: 'Turma',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Foto
            if (_selectedPhoto != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedPhoto!),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Procurar Foto'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _clearPhoto,
                  icon: const Icon(Icons.delete),
                  label: const Text('Limpar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(widget.studentId == null ? 'Salvar' : 'Atualizar'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Cancelar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    super.dispose();
  }
}
