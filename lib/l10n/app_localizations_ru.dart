// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get dateLocale => 'ru_RU';

  @override
  String get noEvents => 'Сегодня занятий нет!';

  @override
  String get noSettings =>
      'Расписание ещё не загружено. Добавьте его в настройках.';

  @override
  String get now => 'СЕЙЧАС';

  @override
  String get minBreak => 'мин. перерыв';

  @override
  String get settings => 'Настройки';

  @override
  String get academicSettings => 'Учебные параметры';

  @override
  String get studyType => 'Тип обучения';

  @override
  String get studyProgram => 'Учебная программа';

  @override
  String get course => 'Курс';

  @override
  String get group => 'Группа';

  @override
  String get subgroups => 'Подгруппы';

  @override
  String get subgroupNumber => 'Номер подгруппы';

  @override
  String get chooseSubgroups => 'Изменить подгруппы';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get editTheme => 'Изменение цветовой схемы приложения';

  @override
  String get selectYourStudyType => 'Выберите тип обучения';

  @override
  String get selectYourStudyTypeAndStudyProgramFirst =>
      'Сначала выберите тип обучения и учебную программу';

  @override
  String get selectYourStudyTypeStudyProgramAndCourseFirst =>
      'Сначала выберите тип обучения, учебную программу и курс';

  @override
  String get selectYourStudyProgram => 'Выберите учебную программу';

  @override
  String get selectYourStudyProgramAndCourseFirst =>
      'Сначала выберите учебную программу и курс';

  @override
  String get selectYourStudyProgramFirst =>
      'Сначала выберите учебную программу';

  @override
  String get selectYourCourse => 'Выберите курс';

  @override
  String get selectYourCourseFirst => 'Сначала выберите курс';

  @override
  String get selectYourGroup => 'Выберите группу';

  @override
  String get subgroupsSelectionEmpty => 'Занятия не найдены.';

  @override
  String get cancel => 'Отменить';

  @override
  String get remove => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get scheduleSectionTitle => 'Расписание';

  @override
  String get scheduleMissing => 'Файл расписания отсутствует';

  @override
  String scheduleStats(Object events, Object subjects) {
    return '$subjects предметов • $events занятий';
  }

  @override
  String scheduleDateRange(Object end, Object start) {
    return 'с $start по $end';
  }

  @override
  String get changeSchedule => 'Изменить расписание';

  @override
  String get uploadSchedule => 'Загрузить расписание';

  @override
  String get whereToGetSchedule => 'Где взять файл расписания?';

  @override
  String get scheduleSourceInstructions =>
      'Откройте сайт tvarkarasciai.vu.lt, найдите свой факультет и группу, нажмите кнопку экспорта в календарь и скачайте файл с расширением .ics. После этого вернитесь сюда и загрузите его через кнопку «Загрузить расписание».';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get scheduleAlreadyExistsTitle => 'Расписание уже существует';

  @override
  String scheduleAlreadyExistsMessage(Object name) {
    return 'Расписание «$name» уже существует. Загрузить его повторно?\n\nПримечание: настройки подгрупп для этого расписания будут сброшены.';
  }

  @override
  String get upload => 'Загрузить';

  @override
  String get parsingError => 'Не удалось распознать файл расписания';

  @override
  String scheduleUnnamed(Object date) {
    return 'Расписание $date';
  }
}
