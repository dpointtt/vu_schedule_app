import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:vu_schedule_app/db/tables/notes.dart';
import 'package:vu_schedule_app/db/tables/schedule_events.dart';
import 'package:vu_schedule_app/db/tables/schedules.dart';
import 'package:vu_schedule_app/db/tables/subgroups.dart';
import 'package:vu_schedule_app/db/tables/subjects.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Schedules,
    Subjects,
    Subgroups,
    ScheduleEvents,
    Notes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'vu_schedule'));

  @override
  int get schemaVersion => 1;

}