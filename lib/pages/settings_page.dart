import 'package:flutter/material.dart';
import 'package:vu_parser/vu_parser.dart';
import 'package:vu_schedule_app/pages/settings_selection_page.dart';
import 'package:vu_schedule_app/pages/subgroups_selection_page.dart';
import 'package:vu_schedule_app/styles/colors.dart';

import '../l10n/app_localizations.dart';
import '../storage/app_language.dart';
import '../storage/settings_repository.dart';
import '../storage/storage_service.dart';
import '../storage/user_settings.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SettingsPage({super.key, required this.onLanguageChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  final client = VUClient();
  UserSettings? settings;

  bool settingsChanged = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await SettingsRepository.load();

    if (!mounted) return;

    setState(() {
      settings = loaded;
    });
  }

  Future<void> _selectStudyType() async {
    final selected = await Navigator.push<StudyType>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsSelectionPage<StudyType>(
          title: AppLocalizations.of(context)!.studyType,
          items: StudyType.values,
          selected: settings?.studyTypeId == null
              ? null
              : StudyType.fromId(settings!.studyTypeId!),
          labelBuilder: (type) => type.displayName,
          onSelected: (type) {
            Navigator.pop(context, type);
          },
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    final current = settings?.studyTypeId == null
        ? null
        : StudyType.fromId(settings!.studyTypeId!);

    if (selected == current) {
      return;
    }

    await StorageService.setStudyTypeId(selected.id);

    await StorageService.removeStudyProgramName();
    await StorageService.removeCourseNumber();
    await StorageService.removeGroupNumber();
    await StorageService.removeGroupScheduleUrl();

    settingsChanged = true;

    await _loadSettings();
  }

  Future<void> _selectStudyProgram() async {
    if (settings?.studyTypeId == null) {
      return;
    }

    await _runAsyncAction(() async {
      final response = await client.fetchPrograms(
        StudyType.fromId(settings!.studyTypeId!),
      );
      final programs = ProgramSelectorParser.parseSelectablePrograms(response);
      final programNames = programs.map((program) => program.label).toList();
      final selected = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => SettingsSelectionPage<String>(
            title: AppLocalizations.of(context)!.studyProgram,
            items: programNames,
            selected: settings!.studyProgramName,
            labelBuilder: (item) => item,
            onSelected: (item) {
              Navigator.pop(context, item);
            },
          ),
        ),
      );

      if (selected == null) {
        return;
      }

      if (selected == settings?.studyProgramName) {
        return;
      }

      await StorageService.setStudyProgramName(selected);

      await StorageService.removeCourseNumber();
      await StorageService.removeGroupNumber();
      await StorageService.removeGroupScheduleUrl();

      settingsChanged = true;

      await _loadSettings();
    });
  }

  Future<void> _selectCourse() async {
    if (settings?.studyProgramName == null) {
      return;
    }

    await _runAsyncAction(() async {
      final response = await client.fetchCourses(
        StudyType.fromId(settings!.studyTypeId!),
        settings!.studyProgramName!,
      );

      final courseObjects = ProgramSelectorParser.parseSelectableCourses(
        response,
      );

      final courses = courseObjects.map((course) => course.number!).toList();

      final selected = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => SettingsSelectionPage<int>(
            title: AppLocalizations.of(context)!.course,
            items: courses,
            selected: settings!.courseNumber,
            labelBuilder: (item) {
              return '$item '
                  '${AppLocalizations.of(context)!.course}';
            },
            onSelected: (item) {
              Navigator.pop(context, item);
            },
          ),
        ),
      );

      if (selected == null) {
        return;
      }

      if (selected == settings?.courseNumber) {
        return;
      }

      await StorageService.setCourseNumber(selected);

      await StorageService.removeGroupNumber();
      await StorageService.removeGroupScheduleUrl();

      settingsChanged = true;

      await _loadSettings();
    });
  }

  Future<void> _selectGroup() async {
    if (settings?.courseNumber == null) {
      return;
    }

    await _runAsyncAction(() async {
      final response = await client.fetchGroups(
        StudyType.fromId(settings!.studyTypeId!),
        settings!.studyProgramName!,
        settings!.courseNumber!,
      );

      final groups = ProgramSelectorParser.parseGroups(response);

      StudyGroup? currentGroup;

      final currentUrl = settings?.groupScheduleUrl;

      if (currentUrl != null) {
        for (final group in groups) {
          if (group.toSchedulePathSegment() == currentUrl) {
            currentGroup = group;
            break;
          }
        }
      }

      final selected = await Navigator.push<StudyGroup>(
        context,
        MaterialPageRoute(
          builder: (_) => SettingsSelectionPage<StudyGroup>(
            title: AppLocalizations.of(context)!.group,
            items: groups,
            selected: currentGroup,
            labelBuilder: (group) => group.label,
            onSelected: (group) {
              Navigator.pop(context, group);
            },
          ),
        ),
      );

      if (selected == null) {
        return;
      }

      final groupNumber = groups.indexOf(selected) + 1;

      if (groupNumber <= 0) {
        return;
      }

      final scheduleUrl = selected.toSchedulePathSegment();

      if (scheduleUrl == settings?.groupScheduleUrl) {
        return;
      }

      await StorageService.setGroupNumber(groupNumber);

      await StorageService.setGroupScheduleUrl(scheduleUrl);

      settingsChanged = true;

      await _loadSettings();
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

    if (selected == null) {
      return;
    }

    if (selected == settings?.appLanguage) {
      return;
    }

    await StorageService.setLanguage(selected);

    settingsChanged = true;

    widget.onLanguageChanged?.call(selected);

    await _loadSettings();
  }

  Future<void> _selectSubgroups() async {
    if (settings?.groupScheduleUrl == null) return;

    await _runAsyncAction(() async {
      final scheduleUrl = settings!.groupScheduleUrl!;
      final uniqueEvents = <String, ScheduleEvent>{};

      final now = DateTime.now();
      try {
        final response = await client.fetchScheduleBetweenDatesWithPath(
          scheduleUrl,
          now.subtract(Duration(days: 30)),
          now.add(Duration(days: 30)),
        );
        final events = ScheduleParser.parse(response);

        for (final event in events) {
          if (event.className != null && event.className!.isNotEmpty) {
            uniqueEvents[event.className!] = event;
          }
        }
      } catch (_) {}

      if (!mounted) return;

      final eventsList = uniqueEvents.values.toList();

      eventsList.sort((a, b) => a.title.compareTo(b.title));

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubgroupsSelectionPage(events: eventsList),
        ),
      );

      settingsChanged = true;
      await _loadSettings();
    });
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
              _SectionTitle(AppLocalizations.of(context)!.academicSettings),

              const SizedBox(height: 14),

              _SettingsCard(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.studyType,
                    value: _studyTypeSelectedText(settings!),
                    enabled: true,
                    onTap: _selectStudyType,
                  ),

                  _Divider(),

                  _SettingsTile(
                    title: AppLocalizations.of(context)!.studyProgram,
                    value: _studyProgramSelectedText(settings!),
                    enabled: settings!.studyTypeId != null,
                    onTap: _selectStudyProgram,
                  ),

                  _Divider(),

                  _SettingsTile(
                    title: AppLocalizations.of(context)!.course,
                    value: _courseSelectedText(settings!),
                    enabled: settings!.studyProgramName != null,
                    onTap: _selectCourse,
                  ),

                  _Divider(),

                  _SettingsTile(
                    title: AppLocalizations.of(context)!.group,
                    value: _groupSelectedText(settings!),
                    enabled: settings!.courseNumber != null,
                    onTap: _selectGroup,
                  ),

                  _Divider(),

                  _SettingsTile(
                    title: AppLocalizations.of(context)!.subgroups,
                    value: AppLocalizations.of(context)!.chooseSubgroups,
                    enabled: settings!.groupNumber != null,
                    onTap: _selectSubgroups,
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

  String _groupSelectedText(UserSettings settings) {
    if (settings.studyTypeId == null) {
      return AppLocalizations.of(context)!.selectYourStudyTypeStudyProgramAndCourseFirst;
    }
    if (settings.studyProgramName == null) {
      return AppLocalizations.of(context)!.selectYourStudyProgramAndCourseFirst;
    }
    if (settings.courseNumber == null) {
      return AppLocalizations.of(context)!.selectYourCourseFirst;
    }
    if (settings.groupNumber == null) {
      return AppLocalizations.of(context)!.selectYourGroup;
    }
    return '${settings.groupNumber!.toString()} ${AppLocalizations.of(context)!.group}';
  }

  String _courseSelectedText(UserSettings settings) {
    if (settings.studyTypeId == null) {
      return AppLocalizations.of(context)!.selectYourStudyTypeAndStudyProgramFirst;
    }
    if (settings.studyProgramName == null) {
      return AppLocalizations.of(context)!.selectYourStudyProgramFirst;
    }
    if (settings.courseNumber == null) {
      return AppLocalizations.of(context)!.selectYourCourse;
    }
    return '${settings.courseNumber!.toString()} ${AppLocalizations.of(context)!.course}';
  }

  String _studyProgramSelectedText(UserSettings settings) {
    if (settings.studyTypeId == null) {
      return AppLocalizations.of(context)!.selectYourStudyType;
    }
    if (settings.studyProgramName == null) {
      return AppLocalizations.of(context)!.selectYourStudyProgram;
    }
    return settings.studyProgramName!;
  }

  String _studyTypeSelectedText(UserSettings settings) {
    return settings.studyTypeId == null
        ? AppLocalizations.of(context)!.selectYourStudyType
        : StudyType.fromId(settings.studyTypeId!).displayName;
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 1, color: textColor.withValues(alpha: 0.08)),
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
