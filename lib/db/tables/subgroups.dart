import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/tables/subjects.dart';

class Subgroups extends Table {

  IntColumn get id => integer().autoIncrement()();

  IntColumn get subjectId => integer().references(Subjects, #id)();

  IntColumn get subgroupNumber => integer()();

}