import 'package:vu_schedule_app/storage/storage_service.dart';
import 'package:vu_schedule_app/storage/user_settings.dart';

class SettingsRepository {
  static Future<UserSettings> load() async {
    return UserSettings(
      studyTypeId: await StorageService.getStudyTypeId(),
      studyProgramName: await StorageService.getStudyProgramName(),
      courseNumber: await StorageService.getCourseNumber(),
      groupNumber: await StorageService.getGroupNumber(),
      groupScheduleUrl: await StorageService.getGroupScheduleUrl(),
      subgroups: await StorageService.getSubgroups(),
      appLanguage: await StorageService.getAppLanguage(),
      // darkMode: await StorageService.getDarkMode(),
    );
  }
}