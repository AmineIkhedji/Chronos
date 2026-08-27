import 'package:isar_community/isar.dart';

part 'days.g.dart';

@collection
class Days {
  Id idDay = Isar.autoIncrement;

  late int dayOfWeek;
  late int idHabit;
}
