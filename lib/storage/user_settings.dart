import 'app_language.dart';

class UserSettings {
  UserSettings({
    required this.studyTypeId,
    required this.studyProgramName,
    required this.courseNumber,
    required this.groupNumber,
    required this.groupScheduleUrl,
    required this.subgroups,
    required this.appLanguage
  });

  final int? studyTypeId;
  final String? studyProgramName;
  final int? courseNumber;
  final int? groupNumber;

  final String? groupScheduleUrl;

  final Map<String, int> subgroups;

  final AppLanguage appLanguage;
}