import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class StorageService {
  StorageService._();

  static const String appLanguage = 'appLanguage';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<AppLanguage> getAppLanguage() async {
    final prefs = await _prefs();

    final value = prefs.getString(appLanguage);

    if (value == null) {
      return AppLanguage.lithuanian;
    }

    try {
      return AppLanguage.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      return AppLanguage.lithuanian;
    }
  }

  static Future<void> setLanguage(
      AppLanguage value,
      ) async {
    final prefs = await _prefs();

    await prefs.setString(
      appLanguage,
      jsonEncode(value.toJson()),
    );
  }

}