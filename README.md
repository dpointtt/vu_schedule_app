# VU Schedule

An unofficial Android app for browsing your **Vilnius University** class schedule, built with Flutter. It uses [`vu_parser`](https://github.com/dpointtt/vu_parser) to fetch data directly from the university's own schedule site, so your timetable is always up to date.

## Screenshots

![vu_schedule_screenshots.png](misc/vu_schedule_screenshots.png?raw=true "Main screens")

## Features

- **Day-by-day schedule** — swipe left/right between days or jump to any date with the built-in date picker.
- **Live "now" indicator** — the current class and the break before the next one are highlighted in real time.
- **"Only mine" filter** — show only the classes that match your selected subgroups, or see the whole group's schedule.
- **Per-subject subgroups** — set your subgroup individually for each class so shared/split lectures show correctly.
- **Multi-language UI** — available in English, Lithuanian, Russian, and Ukrainian.
- **Local persistence** — your group and preferences are saved on-device with `shared_preferences`; no account or sign-in required.

## Tech stack

- [Flutter](https://flutter.dev) (Android)
- `shared_preferences` — local settings storage
- `drift` — sqlite database storage
- `icalendar_parser` — .ics files parser
- `flutter_localizations` / `intl` — localization and date formatting
- `flutter_launcher_icons` — app icon generation

## Download

The app isn't published on Google Play yet. Grab the latest APK from the [Releases](https://github.com/dpointtt/vu_schedule_app/releases) page and install it on your Android device.

## Build from source

Only needed if you want to modify the app or contribute — most users should just download the APK above.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.12.2`)
- Android Studio / an Android device or emulator

### Setup

```bash
git clone https://github.com/dpointtt/vu_schedule_app.git
cd vu_schedule_app
flutter pub get
flutter run
```

To build a release APK yourself:

```bash
flutter build apk --release
```

## Usage

1. Export your schedule to an .ics file and open **Settings** and choose this file.
2. Optionally open **Subgroups** to set which subgroup you belong to for classes that are split into several subgroups.
3. Go back to the schedule screen and swipe between days, or use the date picker in the app bar to jump to a specific date.
4. Use the filter toggle in the app bar to switch between **all classes** for your group and **only your classes** (based on your subgroup settings).
5. Open **Settings → Language** to switch the interface between English, Lithuanian, Russian, and Ukrainian.

## Disclaimer

This is an independent, unofficial project and is not affiliated with or endorsed by Vilnius University. It relies on the public schedule site's own endpoints, which may change without notice.
