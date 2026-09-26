import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/app_database.dart';

class SubjectSubgroups {
  final Subject subject;
  final List<int> availableNumbers;

  SubjectSubgroups({required this.subject, required this.availableNumbers});
}

class SubgroupsRepository {
  final AppDatabase database;

  SubgroupsRepository(this.database);

  Future<List<SubjectSubgroups>> getSubjectsWithSubgroups() async {
    final activeSchedule = await (database.select(database.schedules)
      ..where((row) => row.active.equals(true))
      ..limit(1))
        .getSingleOrNull();

    if (activeSchedule == null) return [];

    final query = database.select(database.scheduleEvents).join([
      innerJoin(
        database.subjects,
        database.subjects.id.equalsExp(database.scheduleEvents.subjectId),
      ),
    ])
      ..where(
        database.scheduleEvents.scheduleId.equals(activeSchedule.id) &
        database.scheduleEvents.subgroups.isNotNull(),
      );

    final rows = await query.get();

    final numbersBySubject = <int, Set<int>>{};
    final subjectsById = <int, Subject>{};

    for (final row in rows) {
      final subject = row.readTable(database.subjects);
      final event = row.readTable(database.scheduleEvents);
      final raw = event.subgroups;

      if (raw == null || raw.trim().isEmpty) continue;

      final numbers = raw
          .split(',')
          .map((value) => int.tryParse(value.trim()))
          .whereType<int>();

      subjectsById[subject.id] = subject;
      numbersBySubject.putIfAbsent(subject.id, () => {}).addAll(numbers);
    }

    return numbersBySubject.entries.map((entry) {
      return SubjectSubgroups(
        subject: subjectsById[entry.key]!,
        availableNumbers: entry.value.toList()..sort(),
      );
    }).toList();
  }

  Future<Map<int, int>> getSelectedSubgroups() async {
    final rows = await database.select(database.subgroups).get();
    return {
      for (final row in rows) row.subjectId: row.subgroupNumber,
    };
  }

  Future<void> setSubgroup(int subjectId, int subgroupNumber) {
    return database.transaction(() async {
      await (database.delete(database.subgroups)
        ..where((row) => row.subjectId.equals(subjectId)))
          .go();
      await database.into(database.subgroups).insert(
        SubgroupsCompanion.insert(
          subjectId: subjectId,
          subgroupNumber: subgroupNumber,
        ),
      );
    });
  }

  Future<void> clearSubgroup(int subjectId) {
    return (database.delete(database.subgroups)
      ..where((row) => row.subjectId.equals(subjectId)))
        .go();
  }
}