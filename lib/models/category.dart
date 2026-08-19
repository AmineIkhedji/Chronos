import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id idCategory = Isar.autoIncrement;
  
  late String name;
  late int color;
  late String icon;
}