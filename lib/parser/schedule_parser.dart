import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:vu_schedule_app/parser/parsed_schedule_event.dart';

class ParsedSchedule {
  final String? name;
  final List<ParsedScheduleEvent> events;

  ParsedSchedule({required this.name, required this.events});
}

class ScheduleParser {
  ParsedSchedule parse(String content) {
    final calendar = ICalendar.fromString(content);
    final data = calendar.toJson()['data'];

    final events = data is List
        ? data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((event) => event['type'] == 'VEVENT')
        .map(_parseEvent)
        .whereType<ParsedScheduleEvent>()
        .toList()
        : <ParsedScheduleEvent>[];

    events.sort((a, b) => a.start.compareTo(b.start));

    return ParsedSchedule(
      name: _extractCalendarName(content),
      events: events,
    );
  }

  ParsedScheduleEvent? _parseEvent(Map<String, dynamic> event) {
    final id = event['uid']?.toString();
    final subjectTitle = event['summary']?.toString();

    if (id == null || id.isEmpty) return null;
    if (subjectTitle == null || subjectTitle.isEmpty) return null;

    final start = _parseDateTime(event['dtstart']);
    final end = _parseDateTime(event['dtend']);

    if (start == null || end == null) return null;

    final description = _parseDescription(event['description']?.toString());

    return ParsedScheduleEvent(
      id: id,
      subjectTitle: subjectTitle,
      start: start,
      end: end,
      types: description.types,
      professors: description.professors,
      groups: description.groups,
      subgroups: description.subgroups,
      classroom: event['location']?.toString(),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is IcsDateTime) return value.toDateTime();

    if (value is Map) {
      final dt = value['dt']?.toString();
      if (dt == null || dt.isEmpty) return null;
      return _tryParseIcsDateTime(dt, value['tzid']?.toString());
    }

    if (value is String && value.isNotEmpty) {
      return _tryParseIcsDateTime(value, null);
    }

    return null;
  }

  DateTime? _tryParseIcsDateTime(String dt, String? tzid) {
    try {
      return IcsDateTime(dt: dt, tzid: tzid).toDateTime();
    } catch (_) {
      return null;
    }
  }

  String? _extractCalendarName(String content) {
    final unfolded = content.replaceAll(RegExp(r'\r?\n[ \t]'), '');
    final match =
    RegExp(r'^X-WR-CALNAME:(.*)$', multiLine: true).firstMatch(unfolded);
    final value = match?.group(1)?.trim();

    if (value == null || value.isEmpty) return null;

    return value
        .replaceAll(r'\\', '\x00')
        .replaceAll(RegExp(r'\\[nN]'), ' ')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\;', ';')
        .replaceAll('\x00', '\\');
  }

  _ParsedDescription _parseDescription(String? description) {
    if (description == null) return const _ParsedDescription();

    final unfolded = description.replaceAll(RegExp(r'\r?\n[ \t]'), '');

    final unescaped = unfolded
        .replaceAll(r'\\', '\x00')
        .replaceAll(RegExp(r'\\[nN]'), '\n')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\;', ';')
        .replaceAll('\x00', '\\');

    final fields = <String, String>{};

    for (final block in unescaped.split(RegExp(r'\n\s*\n'))) {
      final separatorIndex = block.indexOf(':');
      if (separatorIndex == -1) continue;

      final key = block.substring(0, separatorIndex).trim();
      final value = block
          .substring(separatorIndex + 1)
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join(' ');

      if (value.isNotEmpty) fields[key] = value;
    }

    return _ParsedDescription(
      types: fields['Tipas'],
      professors: fields['Dėstytojai'],
      groups: fields['Grupės'],
      subgroups: fields['Pogrupiai'],
    );
  }
}

class _ParsedDescription {
  final String? types;
  final String? professors;
  final String? groups;
  final String? subgroups;

  const _ParsedDescription({
    this.types,
    this.professors,
    this.groups,
    this.subgroups,
  });
}