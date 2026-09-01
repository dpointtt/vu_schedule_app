import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lt'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// No description provided for @dateLocale.
  ///
  /// In lt, this message translates to:
  /// **'lt_LT'**
  String get dateLocale;

  /// No description provided for @noEvents.
  ///
  /// In lt, this message translates to:
  /// **'Šiandien paskaitų nėra!'**
  String get noEvents;

  /// No description provided for @noSettings.
  ///
  /// In lt, this message translates to:
  /// **'Nurodykite savo mokomąją grupę nustatymuose!'**
  String get noSettings;

  /// No description provided for @now.
  ///
  /// In lt, this message translates to:
  /// **'DABAR'**
  String get now;

  /// No description provided for @minBreak.
  ///
  /// In lt, this message translates to:
  /// **'min. pertrauka'**
  String get minBreak;

  /// No description provided for @settings.
  ///
  /// In lt, this message translates to:
  /// **'Nustatymai'**
  String get settings;

  /// No description provided for @academicSettings.
  ///
  /// In lt, this message translates to:
  /// **'Akademiniai parametrai'**
  String get academicSettings;

  /// No description provided for @studyType.
  ///
  /// In lt, this message translates to:
  /// **'Studijų tipas'**
  String get studyType;

  /// No description provided for @studyProgram.
  ///
  /// In lt, this message translates to:
  /// **'Studijų programa'**
  String get studyProgram;

  /// No description provided for @course.
  ///
  /// In lt, this message translates to:
  /// **'Kursas'**
  String get course;

  /// No description provided for @group.
  ///
  /// In lt, this message translates to:
  /// **'Grupė'**
  String get group;

  /// No description provided for @subgroups.
  ///
  /// In lt, this message translates to:
  /// **'Pogrupiai'**
  String get subgroups;

  /// No description provided for @subgroupNumber.
  ///
  /// In lt, this message translates to:
  /// **'Pogrupio numeris'**
  String get subgroupNumber;

  /// No description provided for @chooseSubgroups.
  ///
  /// In lt, this message translates to:
  /// **'Pakeisti pogrupius'**
  String get chooseSubgroups;

  /// No description provided for @preferences.
  ///
  /// In lt, this message translates to:
  /// **'Nuostatos'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In lt, this message translates to:
  /// **'Kalba'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In lt, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @editTheme.
  ///
  /// In lt, this message translates to:
  /// **'Programėlės spalvų keitimas'**
  String get editTheme;

  /// No description provided for @selectYourStudyType.
  ///
  /// In lt, this message translates to:
  /// **'Pasirinkite studijų tipą'**
  String get selectYourStudyType;

  /// No description provided for @selectYourStudyTypeAndStudyProgramFirst.
  ///
  /// In lt, this message translates to:
  /// **'Pirmiausia pasirinkite studijų tipą ir studijų programą'**
  String get selectYourStudyTypeAndStudyProgramFirst;

  /// No description provided for @selectYourStudyTypeStudyProgramAndCourseFirst.
  ///
  /// In lt, this message translates to:
  /// **'Pirmiausia pasirinkite studijų tipą, studijų programą ir kursą'**
  String get selectYourStudyTypeStudyProgramAndCourseFirst;

  /// No description provided for @selectYourStudyProgram.
  ///
  /// In lt, this message translates to:
  /// **'Pasirinkite studijų programą'**
  String get selectYourStudyProgram;

  /// No description provided for @selectYourStudyProgramAndCourseFirst.
  ///
  /// In lt, this message translates to:
  /// **'Pirmiausia pasirinkite studijų programą ir kursą'**
  String get selectYourStudyProgramAndCourseFirst;

  /// No description provided for @selectYourStudyProgramFirst.
  ///
  /// In lt, this message translates to:
  /// **'Pirmiausia pasirinkite studijų programą'**
  String get selectYourStudyProgramFirst;

  /// No description provided for @selectYourCourse.
  ///
  /// In lt, this message translates to:
  /// **'Pasirinkite kursą'**
  String get selectYourCourse;

  /// No description provided for @selectYourCourseFirst.
  ///
  /// In lt, this message translates to:
  /// **'Pirmiausia pasirinkite kursą'**
  String get selectYourCourseFirst;

  /// No description provided for @selectYourGroup.
  ///
  /// In lt, this message translates to:
  /// **'Pasirinkite grupę'**
  String get selectYourGroup;

  /// No description provided for @subgroupsSelectionEmpty.
  ///
  /// In lt, this message translates to:
  /// **'Užsiėmimų nerasta.'**
  String get subgroupsSelectionEmpty;

  /// No description provided for @cancel.
  ///
  /// In lt, this message translates to:
  /// **'Atšaukti'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In lt, this message translates to:
  /// **'Pašalinti'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In lt, this message translates to:
  /// **'Išsaugoti'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lt', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lt':
      return AppLocalizationsLt();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
