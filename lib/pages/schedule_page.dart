import 'package:flutter/material.dart';
import 'package:vu_parser/vu_parser.dart';
import 'package:vu_schedule_app/pages/settings_page.dart';
import 'package:vu_schedule_app/styles/colors.dart';
import 'package:vu_schedule_app/utils/events_date_utils.dart';
import 'package:vu_schedule_app/widgets/break_divider.dart';
import 'package:vu_schedule_app/widgets/event_card.dart';
import 'package:vu_schedule_app/widgets/schedule_app_bar.dart';

import '../l10n/app_localizations.dart';
import '../storage/app_language.dart';
import '../storage/settings_repository.dart';
import '../storage/user_settings.dart';

class SchedulePage extends StatefulWidget {
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SchedulePage({super.key, required this.onLanguageChanged});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final DateTime initialDate;
  late DateTime currentDate;
  late PageController _pageController;

  final int _initialPage = 10000;

  bool isNext = true;
  bool showOnlyMine = true;

  final client = VUClient();

  final Map<DateTime, List<ScheduleEvent>> scheduleEvents = {};

  UserSettings? settings;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    initialDate = DateTime(now.year, now.month, now.day);
    currentDate = initialDate;

    _pageController = PageController(initialPage: _initialPage);

    _loadSettings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final loadedSettings = await SettingsRepository.load();

    if (!mounted) return;

    setState(() {
      settings = loadedSettings;
    });

    if (loadedSettings.groupScheduleUrl == null) {
      return;
    }

    await loadAround(currentDate);
  }

  Future<void> loadAround(DateTime date) async {
    final previous = DateUtils.dateOnly(date.subtract(const Duration(days: 1)));

    final current = DateUtils.dateOnly(date);

    final next = DateUtils.dateOnly(date.add(const Duration(days: 1)));

    if (scheduleEvents.length > 20) {
      scheduleEvents.removeWhere(
        (date, _) => date != current && date != next && date != previous,
      );
    }

    await loadSchedule(current);

    await loadSchedule(next);
    await loadSchedule(previous);
  }

  Future<void> loadSchedule(DateTime date) async {
    if (scheduleEvents.containsKey(date)) {
      return;
    }

    final settings = await SettingsRepository.load();

    if (settings.groupScheduleUrl == null) {
      return;
    }

    final scheduleUrl = settings.groupScheduleUrl!;

    final response = await client.fetchScheduleForDateWithPath(scheduleUrl, date);

    if (!mounted) {
      return;
    }

    setState(() {
      scheduleEvents[date] = ScheduleParser.parse(response);
    });
  }

  void _onPageChanged(int index) {
    final newDate = dateForPage(index);

    setState(() {
      isNext = newDate.isAfter(currentDate);
      currentDate = newDate;
    });

    loadAround(newDate);
  }

  void _onDatePickerChanged(DateTime newDate) {
    final difference = newDate.difference(initialDate).inDays;

    setState(() {
      isNext = newDate.isAfter(currentDate);
      currentDate = newDate;
    });

    _pageController.animateToPage(
      _initialPage + difference,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  DateTime dateForPage(int index) {
    final offset = index - _initialPage;

    return DateUtils.dateOnly(initialDate.add(Duration(days: offset)));
  }

  Future<void> _onSettingsButtonPressed() async {
    final settingsChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SettingsPage(onLanguageChanged: widget.onLanguageChanged),
      ),
    );

    if (settingsChanged != true) {
      return;
    }

    await _reloadAfterSettingsChanged();
  }

  Future<void> _reloadAfterSettingsChanged() async {
    final loadedSettings = await SettingsRepository.load();

    if (!mounted) return;

    setState(() {
      settings = loadedSettings;
      scheduleEvents.clear();
    });

    if (loadedSettings.groupScheduleUrl == null) {
      return;
    }

    await loadAround(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        flexibleSpace: ScheduleAppBar(
          currentDate: currentDate,
          onDateChanged: _onDatePickerChanged,
          isNext: isNext,
          showOnlyMine: showOnlyMine,
          onToggleFilter: () {
            setState(() {
              showOnlyMine = !showOnlyMine;
            });
          },
          onSettingsButtonPressed: _onSettingsButtonPressed,
          groupLabel: _groupLabel(settings),
        ),
      ),

      body: _buildBody(settings),
    );
  }

  Widget _buildBody(UserSettings? settings) {
    if (settings == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (settings.groupScheduleUrl == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            AppLocalizations.of(context)!.noSettings,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 18),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final date = dateForPage(index);
        final allEvents = scheduleEvents[date];

        if (allEvents == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (allEvents.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context)!.noEvents,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            ),
          );
        }

        final events = allEvents.where(_isEventForUser).toList();

        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context)!.noEvents,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 20),
          itemCount: events.length * 2 - 1,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              final previousEvent = events[index ~/ 2];

              final nextEvent = events[index ~/ 2 + 1];

              final breakDuration = nextEvent.start.difference(
                previousEvent.end,
              );

              if (breakDuration.inMinutes <= 0) {
                return const SizedBox.shrink();
              }

              return BreakDivider(
                duration: breakDuration,
                isNow: EventsDateUtils.isBreakNow(
                  previousEvent.end,
                  nextEvent.start,
                ),
              );
            }

            final eventIndex = index ~/ 2;

            final event = events[eventIndex];

            return EventCard(
              event: event,
              isNow: EventsDateUtils.isEventNow(event.start, event.end),
            );
          },
        );
      },
    );
  }

  String _groupLabel(UserSettings? settings) {
    if (settings == null) {
      return '';
    }

    final parts = <String>[];

    if (settings.studyProgramName != null) {
      final program = settings.studyProgramName!;
      if (program.length > 12) {
        parts.add('${program.substring(0, 12)}.');
      } else {
        parts.add(program);
      }
    }

    if (settings.courseNumber != null) {
      parts.add('${settings.courseNumber}k.');
    }

    if (settings.groupNumber != null) {
      parts.add('${settings.groupNumber}gr.');
    }

    return parts.join(' ');
  }

  bool _isEventForUser(ScheduleEvent event) {
    if (!showOnlyMine) return true;

    final className = event.className;
    final subgroupsStr = event.subgroups;

    if (className == null ||
        subgroupsStr == null ||
        subgroupsStr.trim().isEmpty) {
      return true;
    }

    final userSubgroup = settings?.subgroups[className];
    if (userSubgroup == null) {
      return true;
    }

    final eventSubgroups = subgroupsStr
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    if (eventSubgroups.isEmpty) {
      return true;
    }

    return eventSubgroups.contains(userSubgroup);
  }
}
