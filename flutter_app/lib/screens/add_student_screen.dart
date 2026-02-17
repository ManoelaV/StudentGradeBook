import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/student_provider.dart';
import '../database.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late DatabaseHelper _database;
  
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _classes = [];
  int? _selectedSchoolId;
  int? _selectedClassId;
  String? _photoPath;
  String _evaluationType = 'Nota';

  @override
  void initState() {
    super.initState();
    _database = DatabaseHelper();
    _loadSchools();
  }

  void _loadSchools() async {
    final schools = await _database.getAllSchools();
    setState(() {
      _schools = schools;
      if (_schools.isNotEmpty && _selectedSchoolId == null) {
        _selectedSchoolId = _schools[0]['id'];
      }
    });
    _loadClasses();
  }

  void _loadClasses() async {
    if (_selectedSchoolId == null) return;
    final classes = await _database.getClassesBySchoolId(_selectedSchoolId!);
    setState(() {
      _classes = classes;
      _selectedClassId = null;
      if (_classes.isNotEmpty) {
        _selectedClassId = _classes[0]['id'];
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar foto: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _photoPath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClassId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma turma')),
        );
        return;
      }

      try {
        await _database.addStudentWithClass(
          _nameController.text,
          _registrationController.text,
          _selectedClassId!,
          _photoPath,
          evaluationType: _evaluationType,
        );

        if (mounted) {
          await context.read<StudentProvider>().loadStudents();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aluno adicionado com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar aluno: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Aluno'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto do aluno
              GestureDetector(
                onTap: _showPhotoOptions,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: _photoPath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_photoPath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque para adicionar foto',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Aluno',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Matrícula (obrigatória)
              TextFormField(
                controller: _registrationController,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Matrícula é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Escola
              _schools.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.amber[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.amber[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nenhuma escola cadastrada.\nCrie uma escola primeiro.',
                              style: TextStyle(color: Colors.amber[700]),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escola',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int?>(
                          value: _selectedSchoolId,
                          isExpanded: true,
                          items: _schools
                              .map<DropdownMenuItem<int?>>((school) =>
                                  DropdownMenuItem<int?>(
                                    value: school['id'] as int,
                                    child: Text(school['name'] as String),
                                  ))
                              .toList(),
                          onChanged: (schoolId) {
                            setState(() {
                              _selectedSchoolId = schoolId;
                            });
                            _loadClasses();
                          },
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              // Tipo de Avaliação
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de Avaliação',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _evaluationType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.assessment),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Nota',
                        child: Text('Avaliado por Nota'),
                      ),
                      DropdownMenuItem(
                        value: 'Parecer',
                        child: Text('Avaliado por Parecer Descritivo (PD)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _evaluationType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_schools.isNotEmpty)
                _classes.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orange[50],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nenhuma turma na escola.\nCrie uma turma primeiro.',
                                style: TextStyle(color: Colors.orange[700]),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Turma',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int?>(
                            value: _selectedClassId,
                            isExpanded: true,
                            items: _classes
                                .map<DropdownMenuItem<int?>>((classData) =>
                                    DropdownMenuItem<int?>(
                                      value: classData['id'] as int,
                                      child: Text(
                                        '${classData['name']} - ${classData['discipline'] ?? ''}',
                                      ),
                                    ))
                                .toList(),
                            onChanged: (classId) {
                              setState(() {
                                _selectedClassId = classId;
                              });
                            },
                          ),
                        ],
                      ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _schools.isEmpty ? null : _submitForm,
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar Aluno'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}