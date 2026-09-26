class ParsedScheduleEvent {
  final String id;
  final String subjectTitle;

  final DateTime start;
  final DateTime end;

  final String? types;
  final String? professors;
  final String? groups;
  final String? subgroups;
  final String? classroom;

  const ParsedScheduleEvent({
    required this.id,
    required this.subjectTitle,
    required this.start,
    required this.end,
    this.types,
    this.professors,
    this.groups,
    this.subgroups,
    this.classroom,
  });

  @override
  String toString() {
    return '''
ParsedScheduleEvent(
  id: $id,
  subjectTitle: $subjectTitle,
  start: $start,
  end: $end,
  types: $types,
  professors: $professors,
  groups: $groups,
  subgroups: $subgroups,
  classroom: $classroom,
)
''';
  }
}
