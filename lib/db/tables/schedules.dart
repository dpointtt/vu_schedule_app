import 'package:drift/drift.dart';

class Schedules extends Table {

  IntColumn get id => integer().autoIncrement()();

  TextColumn get scheduleName => text().unique()();

  BoolColumn get active => boolean()();

}