import 'package:drift/drift.dart';
import 'package:vu_schedule_app/db/app_database.dart';
import 'package:vu_schedule_app/parser/schedule_parser.dart';

class ScheduleEventWithSubject {
  final ScheduleEvent event;
  final Subject? subject;

  ScheduleEventWithSubject({required this.event, this.subject});
}

class ScheduleStats {
  final int eventsCount;
  final int subjectsCount;
  final DateTime? firstEventStart;
  final DateTime? lastEventStart;

  ScheduleStats({
    required this.eventsCount,
    required this.subjectsCount,
    required this.firstEventStart,
    required this.lastEventStart,
  });
}

class ScheduleRepository {
  final AppDatabase database;

  ScheduleRepository(this.database);

  Future<List<ScheduleEvent>> getAllEvents() {
    return database.select(database.scheduleEvents).get();
  }

  Future<List<ScheduleEvent>> getEventsForSchedule(int scheduleId) {
    return (database.select(database.scheduleEvents)
      ..where((row) => row.scheduleId.equals(scheduleId)))
        .get();
  }

  Future<Schedule?> getActiveSchedule() {
    return (database.select(database.schedules)
      ..where((row) => row.active.equals(true))
      ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Schedule>> getAllSchedules() {
    return database.select(database.schedules).get();
  }

  Future<Schedule?> getScheduleByName(String scheduleName) {
    return (database.select(database.schedules)
      ..where((row) => row.scheduleName.equals(scheduleName))
      ..limit(1))
        .getSingleOrNull();
  }

  Future<ScheduleStats> getStatsForSchedule(int scheduleId) async {
    final events = await getEventsForSchedule(scheduleId);

    if (events.isEmpty) {
      return ScheduleStats(
        eventsCount: 0,
        subjectsCount: 0,
        firstEventStart: null,
        lastEventStart: null,
      );
    }

    final sorted = events.toList()..sort((a, b) => a.start.compareTo(b.start));
    final subjectIds = events.map((event) => event.subjectId).toSet();

    return ScheduleStats(
      eventsCount: events.length,
      subjectsCount: subjectIds.length,
      firstEventStart: sorted.first.start,
      lastEventStart: sorted.last.start,
    );
  }

  Future<List<ScheduleEventWithSubject>> getEventsForDay(DateTime day) async {
    final activeSchedule = await getActiveSchedule();
    if (activeSchedule == null) return [];

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final query = database.select(database.scheduleEvents).join([
      leftOuterJoin(
        database.subjects,
        database.subjects.id.equalsExp(database.scheduleEvents.subjectId),
      ),
    ])
      ..where(
        database.scheduleEvents.scheduleId.equals(activeSchedule.id) &
        database.scheduleEvents.start.isSmallerThanValue(end) &
        database.scheduleEvents.end.isBiggerThanValue(start),
      )
      ..orderBy([OrderingTerm(expression: database.scheduleEvents.start)]);

    return query.map((row) {
      return ScheduleEventWithSubject(
        event: row.readTable(database.scheduleEvents),
        subject: row.readTableOrNull(database.subjects),
      );
    }).get();
  }

  Future<void> importEvents(ParsedSchedule schedule, String scheduleName) async {
    await database.transaction(() async {
      await disableActiveSchedule();

      final scheduleId = await database.into(database.schedules).insert(
        SchedulesCompanion.insert(scheduleName: scheduleName, active: true),
      );

      await _insertSubjectsAndEvents(schedule, scheduleId);
    });
  }

  Future<void> reImportEvents(ParsedSchedule schedule, int scheduleId) async {
    await database.transaction(() async {
      final subjectIdsToDelete = await (database.selectOnly(database.subjects)
        ..addColumns([database.subjects.id])
        ..where(database.subjects.scheduleId.equals(scheduleId)))
          .map((row) => row.read(database.subjects.id)!)
          .get();

      if (subjectIdsToDelete.isNotEmpty) {
        await (database.delete(database.subgroups)
          ..where((row) => row.subjectId.isIn(subjectIdsToDelete)))
            .go();
      }

      await (database.delete(database.scheduleEvents)
        ..where((row) => row.scheduleId.equals(scheduleId)))
          .go();

      await (database.delete(database.subjects)
        ..where((row) => row.scheduleId.equals(scheduleId)))
          .go();

      await disableActiveSchedule();

      await (database.update(database.schedules)
        ..where((row) => row.id.equals(scheduleId)))
          .write(const SchedulesCompanion(active: Value(true)));

      await _insertSubjectsAndEvents(schedule, scheduleId);
    });
  }

  Future<void> setActiveSchedule(int scheduleId) {
    return database.transaction(() async {
      await disableActiveSchedule();
      await (database.update(database.schedules)
        ..where((row) => row.id.equals(scheduleId)))
          .write(const SchedulesCompanion(active: Value(true)));
    });
  }

  Future<void> _insertSubjectsAndEvents(
      ParsedSchedule schedule,
      int scheduleId,
      ) async {
    final subjectIds = <String, int>{};

    for (final event in schedule.events) {
      if (subjectIds.containsKey(event.subjectTitle)) continue;

      final subjectId = await database.into(database.subjects).insert(
        SubjectsCompanion.insert(
          title: event.subjectTitle,
          scheduleId: scheduleId,
        ),
      );

      subjectIds[event.subjectTitle] = subjectId;
    }

    await database.batch((batch) {
      batch.insertAll(
        database.scheduleEvents,
        schedule.events.map(
              (event) => ScheduleEventsCompanion.insert(
            id: event.id,
            scheduleId: scheduleId,
            subjectId: subjectIds[event.subjectTitle]!,
            start: event.start,
            end: event.end,
            types: Value(event.types),
            professors: Value(event.professors),
            groups: Value(event.groups),
            subgroups: Value(event.subgroups),
            classroom: Value(event.classroom),
          ),
        ),
      );
    });
  }

  Future<void> disableActiveSchedule() {
    return (database.update(database.schedules)
      ..where((row) => row.active.equals(true)))
        .write(const SchedulesCompanion(active: Value(false)));
  }
}