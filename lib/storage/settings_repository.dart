import 'package:vu_schedule_app/storage/storage_service.dart';
import 'package:vu_schedule_app/storage/user_settings.dart';

class SettingsRepository {
  static Future<UserSettings> load() async {
    return UserSettings(
      appLanguage: await StorageService.getAppLanguage(),
    );
  }
}