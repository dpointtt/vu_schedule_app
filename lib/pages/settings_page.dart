import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vu_schedule_app/db/app_database.dart';
import 'package:vu_schedule_app/db/database.dart';
import 'package:vu_schedule_app/db/repositories/schedule_repository.dart';
import 'package:vu_schedule_app/pages/settings_selection_page.dart';
import 'package:vu_schedule_app/pages/subgroups_selection_page.dart';
import 'package:vu_schedule_app/parser/schedule_parser.dart';
import 'package:vu_schedule_app/styles/colors.dart';

import '../l10n/app_localizations.dart';
import '../storage/app_language.dart';
import '../storage/settings_repository.dart';
import '../storage/storage_service.dart';
import '../storage/user_settings.dart';

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

class SettingsPage extends StatefulWidget {
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SettingsPage({super.key, required this.onLanguageChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  UserSettings? settings;

  bool settingsChanged = false;

  final ScheduleRepository scheduleRepository = ScheduleRepository(database);

  Schedule? activeSchedule;
  List<Schedule> allSchedules = [];
  ScheduleStats stats = ScheduleStats(
    eventsCount: 0,
    subjectsCount: 0,
    firstEventStart: null,
    lastEventStart: null,
  );

  @override
  void initState() {
    super.initState();

    _loadScheduleData();
    _loadSettings();
  }

  Future<void> _loadScheduleData() async {
    final schedules = await scheduleRepository.getAllSchedules();
    final active = await scheduleRepository.getActiveSchedule();
    final loadedStats = active != null
        ? await scheduleRepository.getStatsForSchedule(active.id)
        : ScheduleStats(
      eventsCount: 0,
      subjectsCount: 0,
      firstEventStart: null,
      lastEventStart: null,
    );

    if (!mounted) return;

    setState(() {
      allSchedules = schedules;
      activeSchedule = active;
      stats = loadedStats;
    });
  }

  Future<void> _loadSettings() async {
    final loaded = await SettingsRepository.load();

    if (!mounted) return;

    setState(() {
      settings = loaded;
    });
  }

  Future<void> _selectIcsFile() async {
    await _runAsyncAction(() async {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['ics'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);

      final parser = ScheduleParser();
      final schedule = parser.parse(content);

      if (schedule.events.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.parsingError)),
        );

        return;
      }

      final scheduleName = schedule.name ??
          AppLocalizations.of(context)!.scheduleUnnamed(_formatDate(DateTime.now()));
      final existingSchedule =
      await scheduleRepository.getScheduleByName(scheduleName);

      if (existingSchedule != null) {
        if (!mounted) return;

        final shouldImportAgain = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: secondaryColor,
            title: Text(
              AppLocalizations.of(context)!.scheduleAlreadyExistsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.scheduleAlreadyExistsMessage(scheduleName),
              style: TextStyle(color: textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: textColor.withValues(alpha: 0.6)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.upload,
                  style: TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
        );

        if (shouldImportAgain != true) return;

        await scheduleRepository.reImportEvents(schedule, existingSchedule.id);
      } else {
        await scheduleRepository.importEvents(schedule, scheduleName);
      }

      settingsChanged = true;

      await _loadScheduleData();
    });
  }

  Future<void> _selectLanguage() async {
    final selected = await Navigator.push<AppLanguage>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsSelectionPage<AppLanguage>(
          title: AppLocalizations.of(context)!.language,
          items: AppLanguage.values,
          selected: settings?.appLanguage,
          labelBuilder: (language) => language.name,
          onSelected: (language) {
            Navigator.pop(context, language);
          },
        ),
      ),
    );

    if (selected == null) return;
    if (selected == settings?.appLanguage) return;

    await StorageService.setLanguage(selected);

    settingsChanged = true;

    widget.onLanguageChanged?.call(selected);

    await _loadSettings();
  }

  Future<void> _openSubgroupsSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubgroupsSelectionPage()),
    );

    settingsChanged = true;
  }

  Future<void> _openScheduleSwitcher() async {
    final selected = await showDialog<Schedule>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          AppLocalizations.of(context)!.changeSchedule,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        children: allSchedules.map((schedule) {
          final isActive = schedule.id == activeSchedule?.id;

          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, schedule),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.circle_outlined,
                  color: isActive ? Colors.green : textColor.withValues(alpha: 0.4),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    schedule.scheduleName,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected.id == activeSchedule?.id) return;

    await scheduleRepository.setActiveSchedule(selected.id);

    settingsChanged = true;

    await _loadScheduleData();
  }

  Future<void> _showScheduleSourceInfo() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.whereToGetSchedule,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.scheduleSourceInstructions,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'https://tvarkarasciai.vu.lt',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: textColor.withValues(alpha: 0.6)),
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'https://tvarkarasciai.vu.lt'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.linkCopied)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAsyncAction(Future<void> Function() action) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,

          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context, settingsChanged);
              },
              color: textColor,
            ),
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            children: [
              _SectionTitle(AppLocalizations.of(context)!.scheduleSectionTitle),

              const SizedBox(height: 14),

              _ScheduleStatusCard(
                activeSchedule: activeSchedule,
                stats: stats,
              ),

              const SizedBox(height: 12),

              if (allSchedules.length > 1) ...[
                _ActionButton(
                  icon: Icons.swap_horiz,
                  label: AppLocalizations.of(context)!.changeSchedule,
                  onTap: _openScheduleSwitcher,
                ),
                const SizedBox(height: 10),
              ],

              _ActionButton(
                icon: Icons.upload_file,
                label: AppLocalizations.of(context)!.uploadSchedule,
                onTap: _selectIcsFile,
              ),

              const SizedBox(height: 10),

              _ActionButton(
                icon: Icons.help_outline,
                label: AppLocalizations.of(context)!.whereToGetSchedule,
                onTap: _showScheduleSourceInfo,
              ),

              const SizedBox(height: 30),

              _SectionTitle(AppLocalizations.of(context)!.academicSettings),

              const SizedBox(height: 14),

              _SettingsCard(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.subgroups,
                    value: AppLocalizations.of(context)!.chooseSubgroups,
                    enabled: stats.subjectsCount > 0,
                    onTap: _openSubgroupsSelection,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _SectionTitle(AppLocalizations.of(context)!.preferences),

              const SizedBox(height: 14),

              _SettingsCard(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.language,
                    value: settings!.appLanguage.name,
                    enabled: true,
                    onTap: _selectLanguage,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _ScheduleStatusCard extends StatelessWidget {
  final Schedule? activeSchedule;
  final ScheduleStats stats;

  const _ScheduleStatusCard({
    required this.activeSchedule,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isMissing = activeSchedule == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.calendar_month, color: textColor, size: 42),
              Positioned(
                right: -6,
                top: -6,
                child: Icon(
                  isMissing ? Icons.warning_rounded : Icons.check_circle,
                  color: isMissing ? Colors.amber : Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMissing
                      ? AppLocalizations.of(context)!.scheduleMissing
                      : activeSchedule!.scheduleName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (!isMissing) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.scheduleStats(stats.subjectsCount, stats.eventsCount),
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  if (stats.firstEventStart != null && stats.lastEventStart != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.scheduleDateRange(
                        _formatDate(stats.firstEventStart!),
                        _formatDate(stats.lastEventStart!),
                      ),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: accentColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String value;
  final bool enabled;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.value,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.35;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Opacity(
              opacity: opacity,
              child: Icon(
                Icons.chevron_right,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}