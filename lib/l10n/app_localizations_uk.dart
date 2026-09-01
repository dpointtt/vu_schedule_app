// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get dateLocale => 'uk_UA';

  @override
  String get noEvents => 'Сьогодні занять немає!';

  @override
  String get noSettings => 'Вкажіть свою навчальну групу в налаштуваннях!';

  @override
  String get now => 'ЗАРАЗ';

  @override
  String get minBreak => 'хв. перерва';

  @override
  String get settings => 'Налаштування';

  @override
  String get academicSettings => 'Навчальні параметри';

  @override
  String get studyType => 'Тип навчання';

  @override
  String get studyProgram => 'Навчальна програма';

  @override
  String get course => 'Курс';

  @override
  String get group => 'Група';

  @override
  String get subgroups => 'Підгрупи';

  @override
  String get subgroupNumber => 'Номер підгрупи';

  @override
  String get chooseSubgroups => 'Змінити підгрупи';

  @override
  String get preferences => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get theme => 'Тема';

  @override
  String get editTheme => 'Зміна колірної схеми застосунку';

  @override
  String get selectYourStudyType => 'Оберіть тип навчання';

  @override
  String get selectYourStudyTypeAndStudyProgramFirst =>
      'Спочатку оберіть тип навчання та навчальну програму';

  @override
  String get selectYourStudyTypeStudyProgramAndCourseFirst =>
      'Спочатку оберіть тип навчання, навчальну програму та курс';

  @override
  String get selectYourStudyProgram => 'Оберіть навчальну програму';

  @override
  String get selectYourStudyProgramAndCourseFirst =>
      'Спочатку оберіть навчальну програму та курс';

  @override
  String get selectYourStudyProgramFirst =>
      'Спочатку оберіть навчальну програму';

  @override
  String get selectYourCourse => 'Оберіть курс';

  @override
  String get selectYourCourseFirst => 'Спочатку оберіть курс';

  @override
  String get selectYourGroup => 'Оберіть групу';

  @override
  String get subgroupsSelectionEmpty => 'Заняття не знайдені.';

  @override
  String get cancel => 'Відмінити';

  @override
  String get remove => 'Видалити';

  @override
  String get save => 'Зберегти';
}
