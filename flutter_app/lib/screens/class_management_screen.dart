import 'package:flutter/material.dart';
import '../database.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _schools = [];
  Map<int, List<Map<String, dynamic>>> _classesBySchool = {};
  
  final _nameController = TextEditingController();
  final _periodController = TextEditingController();
  final _disciplineController = TextEditingController();
  final _professorController = TextEditingController();
  final _shiftController = TextEditingController();
  final _codeController = TextEditingController();
  final _plannedLessonsController = TextEditingController();
  final _academicPeriodController = TextEditingController();
  final _yearController = TextEditingController();
  int? _selectedSchoolId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _periodController.dispose();
    _disciplineController.dispose();
    _professorController.dispose();
    _shiftController.dispose();
    _codeController.dispose();
    _plannedLessonsController.dispose();
    _academicPeriodController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final schools = await _db.getAllSchools();
    final classesBySchool = <int, List<Map<String, dynamic>>>{};
    
    for (var school in schools) {
      final classes = await _db.getClassesBySchoolId(school['id']);
      classesBySchool[school['id']] = classes;
    }
    
    setState(() {
      _schools = schools;
      _classesBySchool = classesBySchool;
    });
  }

  Future<void> _addClass() async {
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma escola')),
      );
      return;
    }
    
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da turma')),
      );
      return;
    }

    try {
      await _db.addClass(
        _selectedSchoolId!,
        name,
        _periodController.text.isNotEmpty ? _periodController.text : null,
        _disciplineController.text.isNotEmpty ? _disciplineController.text : null,
        _professorController.text.isNotEmpty ? _professorController.text : null,
        _shiftController.text.isNotEmpty ? _shiftController.text : null,
        _codeController.text.isNotEmpty ? _codeController.text : null,
        _plannedLessonsController.text.isNotEmpty ? int.tryParse(_plannedLessonsController.text) : null,
        _academicPeriodController.text.isNotEmpty ? _academicPeriodController.text : null,
        _yearController.text.isNotEmpty ? int.tryParse(_yearController.text) ?? DateTime.now().year : DateTime.now().year,
      );
      _clearForm();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Turma adicionada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao adicionar turma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _periodController.clear();
    _disciplineController.clear();
    _professorController.clear();
    _shiftController.clear();
    _codeController.clear();
    _plannedLessonsController.clear();
    _academicPeriodController.clear();
    _yearController.clear();
    _codeController.clear();
    _selectedSchoolId = null;
  }

  Future<void> _deleteClass(int classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir turma'),
        content: Text(
          'Deseja realmente excluir a turma "$className"?\n\n'
          'Isso não excluirá os alunos, mas eles perderão a vinculação com a turma.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _db.deleteClass(classId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Turma excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao excluir turma: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Turmas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecionar Escola',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedSchoolId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Selecione uma escola'),
              items: _schools.map((school) {
                return DropdownMenuItem<int>(
                  value: school['id'],
                  child: Text(school['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSchoolId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Adicionar Nova Turma',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Nome da Turma',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _disciplineController,
              decoration: const InputDecoration(
                hintText: 'Disciplina',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _professorController,
                    decoration: const InputDecoration(
                      hintText: 'Professor',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _shiftController,
                    decoration: const InputDecoration(
                      hintText: 'Turno',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Código',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _plannedLessonsController,
                    decoration: const InputDecoration(
                      hintText: 'Aulas Previstas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _academicPeriodController,
              decoration: const InputDecoration(
                hintText: 'Período Letivo (ex: 1º Trimestre)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                hintText: 'Ano da Turma (ex: 2025, 2026)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedSchoolId != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              ..._classesBySchool[_selectedSchoolId]?.map((classItem) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.class_, color: Colors.blue),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            classItem['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteClass(classItem['id'], classItem['name']);
                          },
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🏫 ${_schools.firstWhere((s) => s['id'] == _selectedSchoolId)['name']}'),
                        if (classItem['discipline'] != null)
                          Text(classItem['discipline']),
                      ],
                    ),
                    children: [
                      Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (classItem['discipline'] != null)
                              _buildInfoRow('Disciplina:', classItem['discipline']),
                            if (classItem['professor'] != null)
                              _buildInfoRow('Professor:', classItem['professor']),
                            if (classItem['shift'] != null)
                              _buildInfoRow('Turno:', classItem['shift']),
                            if (classItem['code'] != null)
                              _buildInfoRow('Código:', classItem['code']),
                            if (classItem['year'] != null)
                              _buildInfoRow('Ano:', classItem['year'].toString()),
                            if (classItem['planned_lessons'] != null)
                              _buildInfoRow('Aulas Previstas:', classItem['planned_lessons'].toString()),
                            if (classItem['academic_period'] != null)
                              _buildInfoRow('Período Letivo:', classItem['academic_period']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList() ?? [],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
