import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vu_schedule_app/l10n/app_localizations.dart';
import 'package:vu_schedule_app/pages/schedule_page.dart';
import 'package:vu_schedule_app/storage/app_language.dart';
import 'package:vu_schedule_app/storage/settings_repository.dart';
import 'package:vu_schedule_app/styles/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('lt', null);
  await initializeDateFormatting('ru', null);
  await initializeDateFormatting('uk', null);
  await initializeDateFormatting('en', null);

  final settings = await SettingsRepository.load();

  runApp(
    MyApp(
      initialLanguage: settings.appLanguage,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppLanguage initialLanguage;

  const MyApp({
    super.key,
    required this.initialLanguage,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLanguage language;

  @override
  void initState() {
    super.initState();

    language = widget.initialLanguage;
  }

  void _changeLanguage(AppLanguage newLanguage) {
    setState(() {
      language = newLanguage;
    });
  }

  Locale _toLocale(AppLanguage language) {
    final parts =
    language.locale.split('_');

    return Locale(
      parts[0],
      parts.length > 1
          ? parts[1]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VU Schedule',

      locale: _toLocale(language),

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: accentColor,
          surface: backgroundColor,
          secondary: secondaryColor,
        ),
        iconTheme: const IconThemeData(
          color: textColor,
        ),
        fontFamily: 'Hanken Grotesk',
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('lt'),
        Locale('ru'),
        Locale('uk'),
        Locale('en'),
      ],

      home: SchedulePage(onLanguageChanged: _changeLanguage),
    );
  }
}



