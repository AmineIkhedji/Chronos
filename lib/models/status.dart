import 'package:isar_community/isar.dart';

part 'status.g.dart';

@collection
class Status {
  Id idStatus = Isar.autoIncrement;
  
  late String name;
  late int color;
  late String icon;
}