import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../database.dart';

class PDFGenerator {
  static Future<File> generateClassGradesPDF(
    String school,
    String className,
    List<Map<String, dynamic>> students,
    DatabaseHelper db,
  ) async {
    final pdf = pw.Document();

    // Carregar notas de cada aluno
    final studentsWithGrades = <Map<String, dynamic>>[];
    for (var student in students) {
      final grades = await db.getStudentGrades(student['id']);
      final total = await db.getStudentTotal(student['id']);
      studentsWithGrades.add({
        ...student,
        'grades': grades,
        'total': total,
      });
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Relatório de Notas',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Escola: $school'),
                  pw.Text('Turma: $className'),
                  pw.Text('Data: ${DateTime.now().toString().split(' ')[0]}'),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            ...studentsWithGrades.map((student) {
              final grades = student['grades'] as List<Map<String, dynamic>>;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    student['name'] ?? 'Sem nome',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  if (student['registration_number'] != null)
                    pw.Text('Matrícula: ${student['registration_number']}'),
                  pw.SizedBox(height: 8),
                  if (grades.isEmpty)
                    pw.Text('Nenhuma nota registrada')
                  else
                    pw.Table.fromTextArray(
                      headers: ['Disciplina', 'Nota', 'Máximo', 'Data', 'Tipo'],
                      data: grades.map((grade) {
                        return [
                          grade['subject'] ?? '',
                          grade['grade']?.toString() ?? '0',
                          grade['max_grade']?.toString() ?? '0',
                          grade['date'] ?? '',
                          grade['grade_type'] ?? 'Prova',
                        ];
                      }).toList(),
                      cellStyle: const pw.TextStyle(fontSize: 10),
                      headerStyle: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      cellAlignment: pw.Alignment.centerLeft,
                    ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Total: ${student['total']?.toStringAsFixed(2) ?? '0.00'}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 16),
                ],
              );
            }),
          ];
        },
      ),
    );

    // Salvar o PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'notas_${school}_${className}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generateStudentReportPDF(
    Map<String, dynamic> student,
    List<Map<String, dynamic>> grades,
    List<Map<String, dynamic>> observations,
    DatabaseHelper db,
  ) async {
    final pdf = pw.Document();

    final total = await db.getStudentTotal(student['id']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Relatório Individual do Aluno',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Nome: ${student['name'] ?? 'Sem nome'}'),
                  if (student['registration_number'] != null)
                    pw.Text('Matrícula: ${student['registration_number']}'),
                  if (student['school'] != null)
                    pw.Text('Escola: ${student['school']}'),
                  if (student['class'] != null)
                    pw.Text('Turma: ${student['class']}'),
                  pw.Text('Data: ${DateTime.now().toString().split(' ')[0]}'),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Notas',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            if (grades.isEmpty)
              pw.Text('Nenhuma nota registrada')
            else
              pw.Table.fromTextArray(
                headers: ['Disciplina', 'Nota', 'Máximo', 'Data', 'Tipo'],
                data: grades.map((grade) {
                  return [
                    grade['subject'] ?? '',
                    grade['grade']?.toString() ?? '0',
                    grade['max_grade']?.toString() ?? '0',
                    grade['date'] ?? '',
                    grade['grade_type'] ?? 'Prova',
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
              ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Total: ${total.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Observações',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            if (observations.isEmpty)
              pw.Text('Nenhuma observação registrada')
            else
              ...observations.map((obs) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      obs['date'] ?? '',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(obs['observation'] ?? ''),
                    pw.SizedBox(height: 8),
                  ],
                );
              }),
          ];
        },
      ),
    );

    // Salvar o PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'relatorio_${student['name']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generateAttendanceReportPDF(
    String school,
    String className,
    List<Map<String, dynamic>> attendanceData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Relatório de Chamada',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Escola: $school'),
                  pw.Text('Turma: $className'),
                  pw.Text('Data: ${DateTime.now().toString().split(' ')[0]}'),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            if (attendanceData.isEmpty)
              pw.Text('Nenhum registro de chamada')
            else
              pw.Table.fromTextArray(
                headers: ['Data', 'Aluno', 'Status'],
                data: attendanceData.map((record) {
                  return [
                    record['date'] ?? '',
                    record['student_name'] ?? '',
                    (record['present'] == 1) ? 'Presente' : 'Ausente',
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
              ),
          ];
        },
      ),
    );

    // Salvar o PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'chamada_${school}_${className}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static String _normalizeDateString(String dateStr) {
    try {
      // Tenta fazer parse e depois formata para YYYY-MM-DD
      final date = DateTime.tryParse(dateStr.trim());
      if (date != null) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return dateStr.trim();
    } catch (e) {
      return dateStr.trim();
    }
  }

  static Future<Uint8List> generateOfficialAttendanceReportPDF({
    required String schoolName,
    required Map<String, dynamic> classInfo,
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> attendanceRecords,
    required Map<String, int> lessonsByDate,
    required List<Map<String, dynamic>> lessonContent,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final attendanceDateKeys = <String>{};
    for (final record in attendanceRecords) {
      final date = record['date'] as String?;
      if (date != null) {
        attendanceDateKeys.add(date);
      }
    }
    final dateKeys = attendanceDateKeys.toList()..sort();
    final effectiveDateKeys = dateKeys.isEmpty ? [''] : dateKeys;

    final expandedDateKeys = <String>[];
    final expandedDates = <DateTime?>[];
    if (effectiveDateKeys.length == 1 && effectiveDateKeys.first.isEmpty) {
      expandedDateKeys.add('');
      expandedDates.add(null);
    } else {
      for (final key in effectiveDateKeys) {
        // Normalizar a chave para formato YYYY-MM-DD
        final normalizedKey = _normalizeDateString(key);
        var count = 1;
        
        // Procurar pela chave normalizada em lessonsByDate
        if (lessonsByDate.containsKey(normalizedKey)) {
          count = lessonsByDate[normalizedKey] ?? 1;
        } else {
          // Procurar pelas outras chaves em lessonsByDate
          for (final dateKey in lessonsByDate.keys) {
            if (_normalizeDateString(dateKey) == normalizedKey) {
              count = lessonsByDate[dateKey] ?? 1;
              break;
            }
          }
        }
        
        final date = DateTime.tryParse(key);
        for (var i = 0; i < count; i++) {
          expandedDateKeys.add(key);
          expandedDates.add(date);
        }
      }
    }
    final attendanceByStudent = <int, Map<String, int>>{};
    for (final record in attendanceRecords) {
      final studentId = record['student_id'] as int?;
      final date = record['date'] as String?;
      final present = record['present'] as int?;
      if (studentId == null || date == null || present == null) continue;
      attendanceByStudent.putIfAbsent(studentId, () => {});
      attendanceByStudent[studentId]![date] = present;
    }

    int getAbsencesForStudent(int studentId) {
      final map = attendanceByStudent[studentId] ?? {};
      int absences = 0;
      for (final key in expandedDateKeys) {
        final present = map[key];
        if (present == 0) {
          absences += 1;
        }
      }
      return absences;
    }

    String formatNumber(num? value) {
      if (value == null) return '';
      if (value % 1 == 0) return value.toStringAsFixed(0);
      return value.toStringAsFixed(2);
    }

    final aulasPrevistas = classInfo['planned_lessons']?.toString() ?? '';
    final aulasMinistradas = expandedDateKeys.length.toString();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'SECRETARIA MUNICIPAL DE EDUCACAO',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Escola: $schoolName'),
                      pw.Text('Periodo Letivo: ${classInfo['academic_period'] ?? ''}'),
                      pw.Text('Ano/Turma: ${classInfo['year'] ?? DateTime.now().year}/${classInfo['code'] ?? ''}'),
                      pw.Text('Disciplina: ${classInfo['discipline'] ?? ''}'),
                      pw.Text('Professor: ${classInfo['professor'] ?? ''}'),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Turno: ${classInfo['shift'] ?? ''}'),
                    pw.Text('Codigo: ${classInfo['code'] ?? ''}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.LayoutBuilder(
              builder: (context, constraints) {
                final pageWidth = constraints?.maxWidth ?? PdfPageFormat.a4.landscape.availableWidth;
                const fixedWidth = 60 + 160 + 22 + 30 + 30 + 40 + 30;
                final dateWidth = expandedDates.isEmpty
                    ? 10.0
                    : ((pageWidth - fixedWidth) / expandedDates.length).clamp(6.0, 14.0);

                final columnWidths = <int, pw.TableColumnWidth>{
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FixedColumnWidth(160),
                  2: const pw.FixedColumnWidth(22),
                };
                for (var i = 0; i < expandedDates.length; i++) {
                  columnWidths[3 + i] = pw.FixedColumnWidth(dateWidth);
                }
                final baseIndex = 3 + expandedDates.length;
                columnWidths[baseIndex + 0] = const pw.FixedColumnWidth(30);
                columnWidths[baseIndex + 1] = const pw.FixedColumnWidth(30);
                columnWidths[baseIndex + 2] = const pw.FixedColumnWidth(40);
                columnWidths[baseIndex + 3] = const pw.FixedColumnWidth(30);

                pw.Widget textCell(
                  String text, {
                  pw.TextAlign align = pw.TextAlign.center,
                  pw.FontWeight? weight,
                  double fontSize = 8,
                  double vPad = 3,
                }) {
                  return pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: vPad, horizontal: 2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      text,
                      textAlign: align,
                      style: pw.TextStyle(fontSize: fontSize, fontWeight: weight),
                    ),
                  );
                }

                final rows = <pw.TableRow>[];

                rows.add(
                  pw.TableRow(
                    children: [
                      textCell('Matricula', weight: pw.FontWeight.bold),
                      textCell('Aluno', weight: pw.FontWeight.bold),
                      textCell('Nº', weight: pw.FontWeight.bold),
                      ...List.generate(expandedDates.length, (index) {
                        if (index == 0) {
                          return textCell('Dias', weight: pw.FontWeight.bold);
                        }
                        return pw.Container();
                      }),
                      textCell('Nota', weight: pw.FontWeight.bold),
                      textCell('Rec', weight: pw.FontWeight.bold),
                      textCell('Nota Final', weight: pw.FontWeight.bold),
                      textCell('Faltas', weight: pw.FontWeight.bold),
                    ],
                  ),
                );

                rows.add(
                  pw.TableRow(
                    children: [
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      ...expandedDates.map((d) {
                        final label = d == null
                            ? ''
                            : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
                        return textCell(
                          label,
                          fontSize: 7,
                          weight: pw.FontWeight.bold,
                        );
                      }),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                    ],
                  ),
                );

                double totalNota = 0;
                double totalRec = 0;
                double totalFinal = 0;
                int totalFaltas = 0;

                for (var i = 0; i < students.length; i++) {
                  final student = students[i];
                  final studentId = student['id'] as int?;
                  final matricula = student['registration_number']?.toString() ?? '';
                  final name = student['name']?.toString() ?? '';
                  final numero = (i + 1).toString().padLeft(2, '0');
                  final nota = (student['total'] as num?) ?? 0;
                  final rec = 0;
                  final notaFinal = nota;
                  final faltas = studentId == null ? 0 : getAbsencesForStudent(studentId);

                  totalNota += nota;
                  totalRec += rec;
                  totalFinal += notaFinal;
                  totalFaltas += faltas;

                  rows.add(
                    pw.TableRow(
                      children: [
                        textCell(matricula, align: pw.TextAlign.left),
                        textCell(name, align: pw.TextAlign.left),
                        textCell(numero),
                        ...expandedDateKeys.map((key) {
                          final map = attendanceByStudent[studentId] ?? {};
                          final present = map[key];
                          final mark = present == null ? '' : (present == 0 ? 'F' : '.');
                          return textCell(
                            mark,
                            fontSize: 9,
                            weight: mark == 'F' ? pw.FontWeight.bold : null,
                          );
                        }),
                        textCell(formatNumber(nota)),
                        textCell(formatNumber(rec)),
                        textCell(formatNumber(notaFinal)),
                        textCell(faltas.toString()),
                      ],
                    ),
                  );
                }

                rows.add(
                  pw.TableRow(
                    children: [
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      ...List.generate(expandedDateKeys.length, (index) {
                        final isLast = index == expandedDateKeys.length - 1;
                        return textCell(
                          isLast ? 'Totais:' : '',
                          align: pw.TextAlign.left,
                          weight: isLast ? pw.FontWeight.bold : null,
                          fontSize: 7,
                          vPad: 2,
                        );
                      }),
                      textCell(formatNumber(totalNota), fontSize: 7, vPad: 2),
                      textCell(formatNumber(totalRec), fontSize: 7, vPad: 2),
                      textCell(formatNumber(totalFinal), fontSize: 7, vPad: 2),
                      textCell(totalFaltas.toString(), fontSize: 7, vPad: 2),
                    ],
                  ),
                );

                return pw.Table(
                  columnWidths: columnWidths,
                  border: pw.TableBorder.all(width: 0.5),
                  children: rows,
                );
              },
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Text('AULAS PREVISTAS: $aulasPrevistas', style: const pw.TextStyle(fontSize: 8)),
                ),
                pw.SizedBox(width: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Text('AULAS MINISTRADAS: $aulasMinistradas', style: const pw.TextStyle(fontSize: 8)),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.Text('RUBRICA DO PROFESSOR:', style: const pw.TextStyle(fontSize: 8)),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Adicionar página de Registro de Aula
    final filteredLessons = lessonContent.where((lesson) {
      final dateStr = lesson['date']?.toString();
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      final day = DateTime(date.year, date.month, date.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final isInRange = !day.isBefore(start) && !day.isAfter(end);
      return isInRange;
    }).toList();

    if (filteredLessons.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ano/Turma: ${classInfo['year'] ?? DateTime.now().year}/${classInfo['code'] ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'Registro de Aula',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.8),
                    1: const pw.FlexColumnWidth(4),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Data',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Registro de Aula',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Data rows
                    ...filteredLessons.map((lesson) {
                      final dateStr = lesson['date']?.toString() ?? '';
                      final date = DateTime.tryParse(dateStr);
                      final formattedDate = date != null
                          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
                          : dateStr;
                      final content = lesson['content']?.toString() ?? '';

                      return pw.TableRow(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              formattedDate,
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              content,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
