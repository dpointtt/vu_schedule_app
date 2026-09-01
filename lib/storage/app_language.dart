enum AppLanguage {
  lithuanian(name: 'Lietuvių kalba', locale: 'lt_LT'),
  english(name: 'English (US)', locale: 'en_US'),
  russian(name: 'Русский язык', locale: 'ru_RU'),
  ukrainian(name: 'Українська мова', locale: 'uk_UA');


  const AppLanguage({required this.name, required this.locale});

  final String name;
  final String locale;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'locale': locale,
    };
  }

  static AppLanguage fromLocale(String locale) {
    return AppLanguage.values.firstWhere(
          (language) => language.locale == locale,
      orElse: () => AppLanguage.lithuanian,
    );
  }

  static AppLanguage fromJson(Map<String, dynamic> json) {
    return AppLanguage.fromLocale(json['locale']);
  }
}