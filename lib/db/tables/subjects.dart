import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/tables/schedules.dart';

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scheduleId => integer().references(Schedules, #id)();

  TextColumn get title => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {scheduleId, title},
  ];
}