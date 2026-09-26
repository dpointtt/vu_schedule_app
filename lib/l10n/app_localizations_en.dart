// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dateLocale => 'en_US';

  @override
  String get noEvents => 'There are no classes today!';

  @override
  String get noSettings => 'No schedule uploaded yet. Add one in Settings.';

  @override
  String get now => 'NOW';

  @override
  String get minBreak => 'min. break';

  @override
  String get settings => 'Settings';

  @override
  String get academicSettings => 'Academic settings';

  @override
  String get studyType => 'Study type';

  @override
  String get studyProgram => 'Study program';

  @override
  String get course => 'Course';

  @override
  String get group => 'Group';

  @override
  String get subgroups => 'Subgroups';

  @override
  String get subgroupNumber => 'Subgroup number';

  @override
  String get chooseSubgroups => 'Change subgroups';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get editTheme => 'Change app color scheme';

  @override
  String get selectYourStudyType => 'Select your study type';

  @override
  String get selectYourStudyTypeAndStudyProgramFirst =>
      'Select your study type and study program first';

  @override
  String get selectYourStudyTypeStudyProgramAndCourseFirst =>
      'Select your study type, study program and course first';

  @override
  String get selectYourStudyProgram => 'Select your study program';

  @override
  String get selectYourStudyProgramAndCourseFirst =>
      'Select your study program and course first';

  @override
  String get selectYourStudyProgramFirst => 'Select your study program first';

  @override
  String get selectYourCourse => 'Select your course';

  @override
  String get selectYourCourseFirst => 'Select your course first';

  @override
  String get selectYourGroup => 'Select your group';

  @override
  String get subgroupsSelectionEmpty => 'Classes not found.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get scheduleSectionTitle => 'Schedule';

  @override
  String get scheduleMissing => 'No schedule file';

  @override
  String scheduleStats(Object events, Object subjects) {
    return '$subjects subjects • $events classes';
  }

  @override
  String scheduleDateRange(Object end, Object start) {
    return 'from $start to $end';
  }

  @override
  String get changeSchedule => 'Change schedule';

  @override
  String get uploadSchedule => 'Upload schedule';

  @override
  String get whereToGetSchedule => 'Where can I get the schedule file?';

  @override
  String get scheduleSourceInstructions =>
      'Open tvarkarasciai.vu.lt, find your faculty and group, tap the calendar export button and download the .ics file. Then come back here and upload it using the \"Upload schedule\" button.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get scheduleAlreadyExistsTitle => 'Schedule already exists';

  @override
  String scheduleAlreadyExistsMessage(Object name) {
    return 'The schedule \"$name\" already exists. Upload it again?\n\nNote: subgroup settings for this schedule will be reset.';
  }

  @override
  String get upload => 'Upload';

  @override
  String get parsingError => 'Couldn\'t read the schedule file';

  @override
  String scheduleUnnamed(Object date) {
    return 'Schedule $date';
  }
}
