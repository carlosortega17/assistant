import 'dart:developer';
import 'dart:io';

import 'package:assistant/model/group_model.dart';
import 'package:assistant/view/groups/group_update.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Box groupBox;

  @override
  void initState() {
    super.initState();
    groupBox = Hive.box('groups');
  }

  void _exportCSV(final Group group) async {
    final response = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar CSV del grupo?'),
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
    if (response) {
      try {
        String? filepath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Seleccione la ruta del archivo',
        );
        if (filepath != null) {
          final file = File('$filepath/${group.name}.csv');
          String csv = const ListToCsvConverter()
              .convert(group.students.map((value) => [value]).toList());
          file.writeAsString(csv);
        }
      } catch (e) {
        log(e.toString(), name: 'export-csv');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Grupos'),
        ),
        body: ValueListenableBuilder(
          valueListenable: groupBox.listenable(),
          builder: (context, Box box, widget) {
            if (box.isEmpty) {
              return const Center(
                child: Text('Sin grupos'),
              );
            }
            return ListView.builder(
              itemCount: groupBox.length,
              itemBuilder: (context, index) {
                final currentBox = box;
                final groupData = currentBox.getAt(index) as Group;
                return ListTile(
                  title: Text(groupData.name),
                  subtitle:
                      Text('Total de alumnos: ${groupData.students.length}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupUpdate(
                        index: index,
                        group: groupData,
                      ),
                    ),
                  ),
                  onLongPress: () => _exportCSV(groupData),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/groupAdd'),
          tooltip: 'Agregar grupo',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
