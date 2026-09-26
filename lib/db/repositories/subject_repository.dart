import 'package:vu_schedule_app/db/app_database.dart';

class SubjectRepository {

  final AppDatabase database;

  SubjectRepository(this.database);

  Future<List<Subject>> getAllSubjects() {
    return database.select(database.subjects).get();
  }

}