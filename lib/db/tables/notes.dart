import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/tables/schedule_events.dart';
import 'package:vu_schedule_app/db/tables/subjects.dart';

class Notes extends Table {

  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get noteDate => dateTime()();

  TextColumn get scheduleEventId => text().nullable().references(ScheduleEvents, #id)();

  IntColumn get subjectId => integer().nullable().references(Subjects, #id)();

  TextColumn get noteText => text().nullable()();

  TextColumn get noteColor => text().clientDefault(() => '#DCDCDC')();

  IntColumn get noteType => integer().clientDefault(() => 0)();

}