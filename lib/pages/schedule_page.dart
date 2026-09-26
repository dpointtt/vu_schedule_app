import 'package:flutter/material.dart';
import 'package:vu_schedule_app/db/database.dart';
import 'package:vu_schedule_app/db/repositories/schedule_repository.dart';
import 'package:vu_schedule_app/db/repositories/subgroups_repository.dart';
import 'package:vu_schedule_app/l10n/app_localizations.dart';
import 'package:vu_schedule_app/pages/settings_page.dart';
import 'package:vu_schedule_app/storage/app_language.dart';
import 'package:vu_schedule_app/storage/settings_repository.dart';
import 'package:vu_schedule_app/storage/user_settings.dart';
import 'package:vu_schedule_app/styles/colors.dart';
import 'package:vu_schedule_app/utils/events_date_utils.dart';
import 'package:vu_schedule_app/widgets/break_divider.dart';
import 'package:vu_schedule_app/widgets/event_card.dart';
import 'package:vu_schedule_app/widgets/schedule_app_bar.dart';

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

  final ScheduleRepository scheduleRepository = ScheduleRepository(database);
  final SubgroupsRepository subgroupsRepository = SubgroupsRepository(database);
  UserSettings? settings;

  final Map<DateTime, List<ScheduleEventWithSubject>> _eventsCache = {};
  static const int _maxCacheSize = 20;

  String scheduleName = '';
  Map<int, int> selectedSubgroups = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    initialDate = DateUtils.dateOnly(now);
    currentDate = initialDate;
    _pageController = PageController(initialPage: _initialPage);
    _loadScheduleName();
    _prefetchAround(currentDate);
    _loadSelectedSubgroups();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime dateForPage(int index) {
    final offset = index - _initialPage;
    return DateUtils.dateOnly(initialDate.add(Duration(days: offset)));
  }

  Future<List<ScheduleEventWithSubject>> _eventsFor(DateTime day) async {
    final key = DateUtils.dateOnly(day);
    final cached = _eventsCache[key];
    if (cached != null) return cached;

    final events = await scheduleRepository.getEventsForDay(key);
    _eventsCache[key] = events;
    _trimCacheIfNeeded();
    return events;
  }

  void _trimCacheIfNeeded() {
    if (_eventsCache.length <= _maxCacheSize) return;
    final keep = {
      currentDate.subtract(const Duration(days: 1)),
      currentDate,
      currentDate.add(const Duration(days: 1)),
    };
    _eventsCache.removeWhere((day, _) => !keep.contains(day));
  }

  Future<void> _prefetchAround(DateTime day) async {
    await Future.wait([
      _eventsFor(day.subtract(const Duration(days: 1))),
      _eventsFor(day),
      _eventsFor(day.add(const Duration(days: 1))),
    ]);
    if (mounted) setState(() {});
  }

  Future<void> _loadSelectedSubgroups() async {
    final loaded = await subgroupsRepository.getSelectedSubgroups();
    if (!mounted) return;
    setState(() {
      selectedSubgroups = loaded;
    });
  }

  bool _matchesSelectedSubgroup(ScheduleEventWithSubject item) {
    final rawSubgroups = item.event.subgroups;
    if (rawSubgroups == null || rawSubgroups.trim().isEmpty) return true;

    final subjectId = item.subject?.id;
    final selected = subjectId == null ? null : selectedSubgroups[subjectId];
    if (selected == null) return true;

    final availableNumbers = rawSubgroups
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>();

    return availableNumbers.contains(selected);
  }

  List<ScheduleEventWithSubject> _applyFilter(
      List<ScheduleEventWithSubject> events,
      ) {
    if (!showOnlyMine) return events;
    return events.where(_matchesSelectedSubgroup).toList();
  }

  Future<void> _loadScheduleName() async {
    final schedule = await scheduleRepository.getActiveSchedule();
    if (!mounted) return;
    if (schedule != null) {
      setState(() {
        scheduleName = schedule.scheduleName;
      });
    }
  }

  void _onPageChanged(int index) {
    final newDate = dateForPage(index);
    setState(() {
      isNext = newDate.isAfter(currentDate);
      currentDate = newDate;
    });
    _eventsFor(newDate.subtract(const Duration(days: 1)));
    _eventsFor(newDate.add(const Duration(days: 1)));
    _trimCacheIfNeeded();
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
    _prefetchAround(newDate);
  }

  Future<void> _onSettingsButtonPressed() async {
    final dataChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(onLanguageChanged: widget.onLanguageChanged),
      ),
    );
    if (dataChanged == true) {
      _eventsCache.clear();
    }
    await _reloadAfterSettingsChanged();
  }

  Future<void> _reloadAfterSettingsChanged() async {
    final loadedSettings = await SettingsRepository.load();
    if (!mounted) return;
    setState(() {
      settings = loadedSettings;
    });
    await _loadScheduleName();
    await _prefetchAround(currentDate);
    await _loadSelectedSubgroups();
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
          groupLabel: scheduleName,
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final date = dateForPage(index);
          final cached = _eventsCache[date];

          if (cached != null) {
            return _EventsList(scheduleName: scheduleName, events: _applyFilter(cached));
          }

          return FutureBuilder<List<ScheduleEventWithSubject>>(
            future: _eventsFor(date),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _EventsList(scheduleName: scheduleName, events: _applyFilter(snapshot.data!));
            },
          );
        },
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final String scheduleName;
  final List<ScheduleEventWithSubject> events;

  const _EventsList({required this.scheduleName, required this.events});

  @override
  Widget build(BuildContext context) {
    if (scheduleName == '') {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noSettings,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textColor, fontSize: 18),
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noEvents,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textColor, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 20),
      itemCount: events.length * 2 - 1,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          final previousEvent = events[index ~/ 2].event;
          final nextEvent = events[index ~/ 2 + 1].event;
          final breakDuration = nextEvent.start.difference(previousEvent.end);
          if (breakDuration.inMinutes <= 0) {
            return const SizedBox.shrink();
          }
          return BreakDivider(
            duration: breakDuration,
            isNow: EventsDateUtils.isBreakNow(previousEvent.end, nextEvent.start),
          );
        }
        final item = events[index ~/ 2];
        return EventCard(
          title: item.subject!.title,
          event: item.event,
          isNow: EventsDateUtils.isEventNow(item.event.start, item.event.end),
        );
      },
    );
  }
}