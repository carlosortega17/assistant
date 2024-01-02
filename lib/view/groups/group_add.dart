import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:assistant/model/group_model.dart';
import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';

class GroupAdd extends StatefulWidget {
  const GroupAdd({Key? key}) : super(key: key);

  @override
  State<GroupAdd> createState() => _GroupAddState();
}

class _GroupAddState extends State<GroupAdd> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _student = TextEditingController();

  final List<String> _students = [];

  late final Box _groupBox;

  @override
  void initState() {
    super.initState();
    _groupBox = Hive.box('groups');
  }

  void _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      final file = File(result.paths.first.toString());
      final data = file.openRead();
      const d = FirstOccurrenceSettingsDetector(
          eols: ['\n', '\r\n'], textDelimiters: [',']);
      final fields = await data
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(csvSettingsDetector: d))
          .toList();
      _students.clear();
      for (final value in fields) {
        _students.add(value.first);
      }
      _name.text = file.uri.pathSegments.last.split('.').first;
      setState(() {});
    }
  }

  void _addStudent() {
    if (_student.value.text.isNotEmpty) {
      _students.add(_student.value.text);
      _student.text = '';
      setState(() {});
    }
  }

  void _addGroup() {
    if (_form.currentState!.validate() && _students.isNotEmpty) {
      _groupBox.add(Group(name: _name.value.text, students: _students));
      Navigator.of(context).pop();
    }
  }

  void _removeStudent(int index) {
    try {
      _students.removeAt(index);
      setState(() {});
    } catch (ex) {
      log(ex.toString(), name: 'add-group-exception');
    }
  }

  List<TableRow> _getList() {
    List<TableRow> rows = [];
    for (int i = 0; i < _students.length; i++) {
      rows.add(
        TableRow(
          children: [
            Row(
              children: [
                Text(_students[i]),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeStudent(i),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Agregar grupo')),
        body: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Nombre'),
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'El nombre del grupo es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _student,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Alumno'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addStudent,
                      child: const Text('Agregar alumno'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lista de alumnos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Table(
                    children: _getList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.menu,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.group_add),
              label: 'Finalizar',
              onTap: _addGroup,
            ),
            SpeedDialChild(
              child: const Icon(Icons.folder),
              label: 'Importar desde CSV',
              onTap: _importCSV,
            ),
            SpeedDialChild(
              child: const Icon(Icons.cancel),
              label: 'Cancelar',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
