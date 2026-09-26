import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/tables/schedules.dart';
import 'package:vu_schedule_app/db/tables/subjects.dart';

class ScheduleEvents extends Table {

  TextColumn get id => text()();

  IntColumn get scheduleId => integer().references(Schedules, #id)();

  IntColumn get subjectId => integer().references(Subjects, #id)();

  DateTimeColumn get start => dateTime()();

  DateTimeColumn get end => dateTime()();

  TextColumn get types => text().nullable()();

  TextColumn get professors => text().nullable()();

  TextColumn get groups => text().nullable()();

  TextColumn get subgroups => text().nullable()();

  TextColumn get classroom => text().nullable()();

  @override
  Set<Column> get primaryKey => {id, scheduleId};
}