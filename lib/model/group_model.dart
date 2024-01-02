import 'package:hive/hive.dart';

part 'group_model.g.dart';

@HiveType(typeId: 0)
class Group {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<String> students;

  Group({
    required this.name,
    required this.students,
  });
}
