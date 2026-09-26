// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get dateLocale => 'lt_LT';

  @override
  String get noEvents => 'Šiandien paskaitų nėra!';

  @override
  String get noSettings =>
      'Tvarkaraštis dar neįkeltas. Pridėkite jį nustatymuose.';

  @override
  String get now => 'DABAR';

  @override
  String get minBreak => 'min. pertrauka';

  @override
  String get settings => 'Nustatymai';

  @override
  String get academicSettings => 'Akademiniai parametrai';

  @override
  String get studyType => 'Studijų tipas';

  @override
  String get studyProgram => 'Studijų programa';

  @override
  String get course => 'Kursas';

  @override
  String get group => 'Grupė';

  @override
  String get subgroups => 'Pogrupiai';

  @override
  String get subgroupNumber => 'Pogrupio numeris';

  @override
  String get chooseSubgroups => 'Pakeisti pogrupius';

  @override
  String get preferences => 'Nuostatos';

  @override
  String get language => 'Kalba';

  @override
  String get theme => 'Tema';

  @override
  String get editTheme => 'Programėlės spalvų keitimas';

  @override
  String get selectYourStudyType => 'Pasirinkite studijų tipą';

  @override
  String get selectYourStudyTypeAndStudyProgramFirst =>
      'Pirmiausia pasirinkite studijų tipą ir studijų programą';

  @override
  String get selectYourStudyTypeStudyProgramAndCourseFirst =>
      'Pirmiausia pasirinkite studijų tipą, studijų programą ir kursą';

  @override
  String get selectYourStudyProgram => 'Pasirinkite studijų programą';

  @override
  String get selectYourStudyProgramAndCourseFirst =>
      'Pirmiausia pasirinkite studijų programą ir kursą';

  @override
  String get selectYourStudyProgramFirst =>
      'Pirmiausia pasirinkite studijų programą';

  @override
  String get selectYourCourse => 'Pasirinkite kursą';

  @override
  String get selectYourCourseFirst => 'Pirmiausia pasirinkite kursą';

  @override
  String get selectYourGroup => 'Pasirinkite grupę';

  @override
  String get subgroupsSelectionEmpty => 'Užsiėmimų nerasta.';

  @override
  String get cancel => 'Atšaukti';

  @override
  String get remove => 'Pašalinti';

  @override
  String get save => 'Išsaugoti';

  @override
  String get scheduleSectionTitle => 'Tvarkaraštis';

  @override
  String get scheduleMissing => 'Tvarkaraščio failo nėra';

  @override
  String scheduleStats(Object events, Object subjects) {
    return '$subjects dalykų • $events užsiėmimų';
  }

  @override
  String scheduleDateRange(Object end, Object start) {
    return 'nuo $start iki $end';
  }

  @override
  String get changeSchedule => 'Keisti tvarkaraštį';

  @override
  String get uploadSchedule => 'Įkelti tvarkaraštį';

  @override
  String get whereToGetSchedule => 'Kur gauti tvarkaraščio failą?';

  @override
  String get scheduleSourceInstructions =>
      'Atsidarykite svetainę tvarkarasciai.vu.lt, susiraskite savo fakultetą ir grupę, paspauskite kalendoriaus eksporto mygtuką ir atsisiųskite .ics formato failą. Tada grįžkite čia ir įkelkite jį mygtuku „Įkelti tvarkaraštį“.';

  @override
  String get linkCopied => 'Nuoroda nukopijuota';

  @override
  String get scheduleAlreadyExistsTitle => 'Toks tvarkaraštis jau yra';

  @override
  String scheduleAlreadyExistsMessage(Object name) {
    return 'Tvarkaraštis „$name“ jau egzistuoja. Įkelti jį dar kartą?\n\nPastaba: šio tvarkaraščio pogrupių nustatymai bus atstatyti.';
  }

  @override
  String get upload => 'Įkelti';

  @override
  String get parsingError => 'Nepavyko atpažinti tvarkaraščio failo';

  @override
  String scheduleUnnamed(Object date) {
    return 'Tvarkaraštis $date';
  }
}
