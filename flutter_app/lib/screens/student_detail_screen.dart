import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> with SingleTickerProviderStateMixin {
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _maxGradeController = TextEditingController(text: '10');
  final _observationController = TextEditingController();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _regNumController = TextEditingController();
  
  late TabController _tabController;
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _observations = [];
  bool _isEditingStudent = false;
  String? _newPhotoPath;
  String _selectedGradeType = 'Prova'; // Tipo de nota selecionado
  String? _selectedEvaluationType = 'Nota'; // Tipo de avaliação (Nota ou Parecer)
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<StudentProvider>().getStudentDetail(widget.studentId);
    _grades = await context.read<StudentProvider>().getStudentGrades(widget.studentId);
    _observations = await context.read<StudentProvider>().getStudentObservations(widget.studentId);
    setState(() {});
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _maxGradeController.dispose();
    _observationController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _regNumController.dispose();
    _tabController.dispose();
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
          _newPhotoPath = image.path;
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
          _newPhotoPath = photo.path;
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
            if (_newPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover foto nova'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _newPhotoPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _initializeEditFields() {
    final student = context.read<StudentProvider>().currentStudent;
    if (student != null) {
      _nameController.text = student['name'] ?? '';
      // Usar school_name (do JOIN) com fallback para school (campo antigo)
      _schoolController.text = student['school_name'] ?? student['school'] ?? '';
      // Usar class_name (do JOIN) com fallback para class (campo antigo)
      _classController.text = student['class_name'] ?? student['class'] ?? '';
      _regNumController.text = student['registration_number'] ?? '';
      // Inicializar o tipo de avaliação
      _selectedEvaluationType = student['evaluation_type'] ?? 'Nota';
    }
  }

  void _saveStudentChanges() async {
    if (_nameController.text.isEmpty || _schoolController.text.isEmpty || _classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenchimento de nome, escola e série/turma é obrigatório')),
      );
      return;
    }

    try {
      await context.read<StudentProvider>().updateStudent(
        widget.studentId,
        _nameController.text,
        _regNumController.text.isEmpty ? null : _regNumController.text,
        _schoolController.text,
        _classController.text,
        _newPhotoPath ?? context.read<StudentProvider>().currentStudent?['photo_path'],
        evaluationType: _selectedEvaluationType ?? 'Nota',
      );

      setState(() {
        _isEditingStudent = false;
        _newPhotoPath = null;
      });

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Dados do aluno atualizados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro ao atualizar: $e')),
        );
      }
    }
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
      final maxGrade = double.parse(_maxGradeController.text);
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      
      await context.read<StudentProvider>().addGrade(
        widget.studentId,
        _subjectController.text,
        grade,
        maxGrade,
        date,
        gradeType: _selectedGradeType, // Passa o tipo de nota
      );

      _subjectController.clear();
      _gradeController.clear();
      _maxGradeController.text = '10';
      setState(() {
        _selectedGradeType = 'Prova'; // Reseta para o padrão
      });

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Nota adicionada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    }
  }

  void _addObservation() async {
    if (_observationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um parecer')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      
      await context.read<StudentProvider>().addObservation(
        widget.studentId,
        _observationController.text,
        date,
      );

      _observationController.clear();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Parecer salvo com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aluno'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Dados'),
            Tab(icon: Icon(Icons.grade), text: 'Notas'),
            Tab(icon: Icon(Icons.description), text: 'Pareceres'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Chamada'),
          ],
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final student = provider.currentStudent;

          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // ABA 1: DADOS DO ALUNO
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!_isEditingStudent) ...[
                      GestureDetector(
                        onTap: _isEditingStudent ? null : () {
                          _initializeEditFields();
                          setState(() => _isEditingStudent = true);
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: student['photo_path'] != null
                                  ? FileImage(File(student['photo_path']))
                                  : null,
                              child: student['photo_path'] == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        student['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard('Escola', student['school_name'] ?? student['school'] ?? 'Não informada', Icons.school),
                      _buildInfoCard('Série/Turma', student['class_name'] ?? student['class'] ?? 'Não informada', Icons.class_),
                      _buildInfoCard('Matrícula', student['registration_number'] ?? 'Não informada', Icons.badge),
                      _buildInfoCard(
                        'Tipo de Avaliação',
                        student['evaluation_type'] == 'Parecer'
                            ? 'Avaliado por Parecer Descritivo (PD)'
                            : 'Avaliado por Nota',
                        Icons.assessment,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _initializeEditFields();
                            setState(() => _isEditingStudent = true);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Dados'),
                        ),
                      ),
                    ] else ...[
                      // Modo edição
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _newPhotoPath != null
                                  ? FileImage(File(_newPhotoPath!))
                                  : (student['photo_path'] != null
                                      ? FileImage(File(student['photo_path']))
                                      : null),
                              child: (_newPhotoPath == null && student['photo_path'] == null)
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque para alterar foto',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Aluno',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _schoolController,
                        decoration: InputDecoration(
                          labelText: 'Escola',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _classController,
                        decoration: InputDecoration(
                          labelText: 'Série/Turma',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.class_),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _regNumController,
                        decoration: InputDecoration(
                          labelText: 'Matrícula (opcional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEvaluationType,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Avaliação',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.assessment),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Nota',
                            child: const Text('Avaliado por Nota'),
                          ),
                          DropdownMenuItem(
                            value: 'Parecer',
                            child: const Text('Avaliado por Parecer Descritivo (PD)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEvaluationType = value ?? 'Nota';
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditingStudent = false;
                                  _newPhotoPath = null;
                                });
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveStudentChanges,
                              icon: const Icon(Icons.save),
                              label: const Text('Salvar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ABA 2: NOTAS
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicionar Nova Nota',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Disciplina',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _gradeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Nota',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.grade),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxGradeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Máx',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGradeType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Avaliação',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Prova', child: Text('📝 Prova')),
                        DropdownMenuItem(value: 'Trabalho', child: Text('📄 Trabalho')),
                        DropdownMenuItem(value: 'Recuperação', child: Text('🔄 Recuperação')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGradeType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addGrade,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Nota'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Notas Cadastradas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_grades.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.grade, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Nenhuma nota cadastrada'),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ..._grades.map((grade) {
                            final gradeValue = (grade['grade'] as num?)?.toDouble() ?? 0.0;
                            final maxGrade = (grade['max_grade'] as num?)?.toDouble() ?? 10.0;
                            final percentage = (gradeValue / maxGrade * 100).toStringAsFixed(1);
                            final gradeType = grade['grade_type'] ?? 'Prova';
                            
                            // Define cores e ícones baseados no tipo
                            Color avatarColor;
                            IconData typeIcon;
                            switch (gradeType) {
                              case 'Trabalho':
                                avatarColor = Colors.blue;
                                typeIcon = Icons.assignment;
                                break;
                              case 'Recuperação':
                                avatarColor = Colors.orange;
                                typeIcon = Icons.autorenew;
                                break;
                              default: // Prova
                                avatarColor = Colors.purple;
                                typeIcon = Icons.edit_note;
                            }
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: avatarColor,
                                  child: Icon(typeIcon, color: Colors.white),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(grade['subject'] ?? '')),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: gradeValue >= maxGrade * 0.6 ? Colors.green : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        gradeValue.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  '$gradeType • $gradeValue de $maxGrade ($percentage%) • ${grade['date'] ?? ''}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar'),
                                        content: const Text('Deseja realmente excluir esta nota?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await context.read<StudentProvider>().deleteGrade(grade['id']);
                                      await _loadData();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Nota removida!')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildGradesSummary(),
                        ],
                      ),
                  ],
                ),
              ),

              // ABA 3: PARECERES
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Novo Parecer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _observationController,
                      maxLines: 20,
                      minLines: 20,
                      decoration: InputDecoration(
                        hintText: 'Digite aqui o parecer descritivo do aluno...\n\n'
                            'O parecer deve conter informações sobre:\n'
                            '• Desempenho acadêmico\n'
                            '• Comportamento em sala\n'
                            '• Participação nas atividades\n'
                            '• Relacionamento com colegas\n'
                            '• Pontos fortes\n'
                            '• Pontos a desenvolver\n'
                            '• Recomendações',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addObservation,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Parecer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Pareceres Anteriores',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_observations.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.description, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Nenhum parecer cadastrado'),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._observations.map((obs) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          obs['date'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar'),
                                            content: const Text('Deseja realmente excluir este parecer?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirm == true) {
                                          await context.read<StudentProvider>().deleteObservation(obs['id']);
                                          await _loadData();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Parecer removido!')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  obs['observation'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              // ABA 4: HISTÓRICO DE CHAMADA
              Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, _) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: attendanceProvider.getAttendanceHistory(widget.studentId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erro ao carregar histórico: ${snapshot.error}'),
                        );
                      }
                      
                      final records = snapshot.data ?? [];
                      
                      if (records.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum registro de chamada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      int presentCount = records.where((r) => r['present'] == 1).length;
                      int absentCount = records.where((r) => r['present'] == 0).length;
                      double attendancePercentage = (presentCount / records.length * 100);
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: records.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.assessment, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text(
                                        'Resumo de Presença',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Presentes',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            presentCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Ausentes',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            absentCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Frequência',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${attendancePercentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          final record = records[index - 1];
                          final isPresent = record['present'] == 1;
                          final date = record['date'] as String;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isPresent ? Colors.green[50] : Colors.red[50],
                              border: Border.all(
                                color: isPresent ? Colors.green : Colors.red,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPresent ? Colors.green : Colors.red,
                                child: Icon(
                                  isPresent ? Icons.check : Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                isPresent ? 'Presente' : 'Ausente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPresent ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                              subtitle: Text(
                                '${record['school'] ?? 'Sem escola'} - ${record['class'] ?? 'Sem turma'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                date,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesSummary() {
    if (_grades.isEmpty) {
      return const SizedBox.shrink();
    }

    // Verificar o tipo de avaliação do aluno
    final student = context.read<StudentProvider>().currentStudent;
    final evaluationType = (student?['evaluation_type'] as String?) ?? 'Nota';
    
    // Se o aluno é avaliado por parecer, não mostrar resumo de notas
    if (evaluationType == 'Parecer') {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este aluno é avaliado por Parecer Descritivo (PD)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Separar notas: Provas + Trabalhos (SEM Recuperação)
    final gradesWithoutRecovery = _grades.where((g) => (g['grade_type'] ?? 'Prova') != 'Recuperação').toList();
    final recoveryGrades = _grades.where((g) => (g['grade_type'] ?? 'Prova') == 'Recuperação').toList();

    if (gradesWithoutRecovery.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalGrades = gradesWithoutRecovery.length;
    final totalSum = gradesWithoutRecovery.fold<double>(0, (sum, grade) => sum + ((grade['grade'] as num?)?.toDouble() ?? 0.0));
    final average = totalSum / totalGrades;
    final maxGrade = gradesWithoutRecovery.map<double>((g) => (g['grade'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a > b ? a : b);
    final minGrade = gradesWithoutRecovery.map<double>((g) => (g['grade'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a < b ? a : b);

    // Recuperação (se houver)
    double? recoveryGrade;
    if (recoveryGrades.isNotEmpty) {
      recoveryGrade = (recoveryGrades.first['grade'] as num?)?.toDouble();
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Resumo das Notas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Total de Notas (Prova/Trabalho):', '$totalGrades'),
            _buildSummaryRow('Soma Total:', totalSum.toStringAsFixed(2)),
            _buildSummaryRow('Média:', average.toStringAsFixed(2)),
            _buildSummaryRow('Maior Nota:', maxGrade.toStringAsFixed(2)),
            _buildSummaryRow('Menor Nota:', minGrade.toStringAsFixed(2)),
            if (recoveryGrade != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildSummaryRow('Nota de Recuperação:', recoveryGrade.toStringAsFixed(2), color: Colors.orange),
              _buildSummaryRow('Nota Final:', (totalSum > recoveryGrade ? totalSum : recoveryGrade).toStringAsFixed(2), color: Colors.green),
            ],
          ],
        ),
      ),
    );
  }
}
