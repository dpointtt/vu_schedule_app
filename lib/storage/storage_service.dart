import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class StorageService {
  StorageService._();

  static const String studyTypeId = 'studyTypeId';
  static const String studyProgramName = 'studyProgramName';
  static const String courseNumber = 'courseNumber';
  static const String groupNumber = 'groupNumber';

  static const String groupScheduleUrl = 'groupScheduleUrl';

  static const String subgroups = 'subgroups';
  static const String appLanguage = 'appLanguage';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<int?> getStudyTypeId() async {
    final prefs = await _prefs();
    return prefs.getInt(studyTypeId);
  }

  static Future<void> setStudyTypeId(int value) async {
    final prefs = await _prefs();

    // Сохраняем изменение сразу после выбора пользователем.
    await prefs.setInt(studyTypeId, value);
  }

  static Future<void> removeStudyTypeId() async {
    final prefs = await _prefs();
    await prefs.remove(studyTypeId);
  }

  static Future<String?> getStudyProgramName() async {
    final prefs = await _prefs();
    return prefs.getString(studyProgramName);
  }

  static Future<void> setStudyProgramName(String value) async {
    final prefs = await _prefs();

    // Новое значение сразу записывается в SharedPreferences.
    await prefs.setString(studyProgramName, value);
  }

  static Future<void> removeStudyProgramName() async {
    final prefs = await _prefs();
    await prefs.remove(studyProgramName);
  }

  static Future<int?> getCourseNumber() async {
    final prefs = await _prefs();
    return prefs.getInt(courseNumber);
  }

  static Future<void> setCourseNumber(int value) async {
    final prefs = await _prefs();

    // Сохраняем выбранный курс сразу.
    await prefs.setInt(courseNumber, value);
  }

  static Future<void> removeCourseNumber() async {
    final prefs = await _prefs();
    await prefs.remove(courseNumber);
  }

  static Future<int?> getGroupNumber() async {
    final prefs = await _prefs();
    return prefs.getInt(groupNumber);
  }

  static Future<void> setGroupNumber(int value) async {
    final prefs = await _prefs();

    // Сохраняем выбранную группу сразу.
    await prefs.setInt(groupNumber, value);
  }

  static Future<void> removeGroupNumber() async {
    final prefs = await _prefs();
    await prefs.remove(groupNumber);
  }

  static Future<String?> getGroupScheduleUrl() async {
    final prefs = await _prefs();
    return prefs.getString(groupScheduleUrl);
  }

  static Future<void> setGroupScheduleUrl(String value) async {
    final prefs = await _prefs();

    // Сохраняем выбранную группу сразу.
    await prefs.setString(groupScheduleUrl, value);
  }

  static Future<void> removeGroupScheduleUrl() async {
    final prefs = await _prefs();
    await prefs.remove(groupScheduleUrl);
  }

  static Future<Map<String, int>> getSubgroups() async {
    final prefs = await _prefs();

    final value = prefs.getString(subgroups);

    if (value == null) {
      return {};
    }

    final decoded = jsonDecode(value) as Map<String, dynamic>;

    return decoded.map(
          (key, value) => MapEntry(
        key,
        value as int,
      ),
    );
  }

  static Future<void> setSubgroups(
      Map<String, int> value,
      ) async {
    final prefs = await _prefs();

    await prefs.setString(
      subgroups,
      jsonEncode(value),
    );
  }

  static Future<void> removeSubgroup(String className) async {
    final subgroups = await getSubgroups();

    subgroups.remove(className);

    await setSubgroups(subgroups);
  }

  static Future<void> clearSubgroups() async {
    final prefs = await _prefs();
    await prefs.remove(subgroups);
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