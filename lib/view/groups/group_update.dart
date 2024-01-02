import 'package:flutter/material.dart';
import 'package:assistant/model/group_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';

class GroupUpdate extends StatefulWidget {
  final int index;
  final Group group;
  const GroupUpdate({Key? key, required this.index, required this.group})
      : super(key: key);

  @override
  State<GroupUpdate> createState() => _GroupUpdateState();
}

class _GroupUpdateState extends State<GroupUpdate> {
  late final Box _groupBox;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _student = TextEditingController();
  int _selected = -1;

  final List<String> _students = [];

  @override
  void initState() {
    super.initState();
    _groupBox = Hive.box('groups');
    _name.text = widget.group.name;
    for (final student in widget.group.students) {
      _students.add(student);
    }
  }

  void _update() {
    if (_name.value.text.isNotEmpty && _students.isNotEmpty) {
      _groupBox.putAt(
        widget.index,
        Group(
          name: _name.value.text,
          students: _students,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _delete(int index) {
    _students.removeAt(index);
    setState(() {});
  }

  void _selectStudent(int index) {
    _selected = index;
    _student.text = _students[index];
    setState(() {});
  }

  List<Widget> _getRows() {
    final List<Widget> rows = [];
    for (int i = 0; i < _students.length; i++) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_students[i]),
            const Spacer(),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: () => _selectStudent(i),
              icon: const Icon(
                Icons.update_rounded,
                color: Colors.blue,
              ),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => _delete(i),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  void _addStudent() {
    if (_student.value.text.isNotEmpty) {
      if (_selected == -1) {
        _students.add(_student.value.text);
      } else if (_selected != -1) {
        _students[_selected] = _student.value.text;
        _selected = -1;
      }
      setState(() {});
      _student.text = '';
    }
  }

  void _removeGroup() async {
    final bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar grupo?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Si'),
            ),
          ],
        );
      },
    );
    if (result) {
      _groupBox.deleteAt(widget.index);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actualizar grupo'),
        ),
        body: SingleChildScrollView(
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
                    child: Text(
                      _selected == -1 ? 'Agregar alumno' : 'Actualizar alumno',
                    ),
                  ),
                ),
                if (_selected != -1) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        _selected = -1;
                        _student.text = '';
                        setState(() {});
                      },
                      child: const Text('Cancelar actualización'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Lista de alumnos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: _getRows(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.menu,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.group_add),
              label: 'Finalizar',
              onTap: _update,
            ),
            SpeedDialChild(
              child: const Icon(Icons.delete),
              label: 'Eliminar',
              onTap: _removeGroup,
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
