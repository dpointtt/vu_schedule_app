import 'package:flutter/material.dart';
import 'package:vu_schedule_app/db/app_database.dart';
import 'package:vu_schedule_app/db/repositories/subgroups_repository.dart';
import 'package:vu_schedule_app/styles/colors.dart';

import '../l10n/app_localizations.dart';

class SubgroupsSelectionPage extends StatefulWidget {
  const SubgroupsSelectionPage({super.key});

  @override
  State<SubgroupsSelectionPage> createState() =>
      _SubgroupsSelectionPageState();
}

class _SubgroupsSelectionPageState extends State<SubgroupsSelectionPage> {
  final SubgroupsRepository subgroupsRepository =
  SubgroupsRepository(AppDatabase());

  List<SubjectSubgroups> subjects = [];
  Map<int, int> selectedSubgroups = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedSubjects = await subgroupsRepository.getSubjectsWithSubgroups();
    final loadedSelection = await subgroupsRepository.getSelectedSubgroups();

    if (!mounted) return;

    setState(() {
      subjects = loadedSubjects;
      selectedSubgroups = loadedSelection;
      isLoading = false;
    });
  }

  Future<void> _openSubgroupDialog(SubjectSubgroups item) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _SubgroupDialog(
        subject: item.subject,
        availableNumbers: item.availableNumbers,
        currentSubgroup: selectedSubgroups[item.subject.id],
      ),
    );

    if (result == null) return;

    if (result == -1) {
      await subgroupsRepository.clearSubgroup(item.subject.id);
      selectedSubgroups.remove(item.subject.id);
    } else {
      await subgroupsRepository.setSubgroup(item.subject.id, result);
      selectedSubgroups[item.subject.id] = result;
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          AppLocalizations.of(context)!.subgroups,
          style: TextStyle(color: textColor),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context)!.subgroupsSelectionEmpty,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = subjects[index];
          final selectedSubgroup = selectedSubgroups[item.subject.id];

          return Material(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openSubgroupDialog(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.subject.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (selectedSubgroup != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${AppLocalizations.of(context)!.subgroups} $selectedSubgroup',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        color: textColor.withValues(alpha: 0.4),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubgroupDialog extends StatelessWidget {
  final Subject subject;
  final List<int> availableNumbers;
  final int? currentSubgroup;

  const _SubgroupDialog({
    required this.subject,
    required this.availableNumbers,
    required this.currentSubgroup,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Text(
        subject.title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: availableNumbers.map((number) {
          final isSelected = number == currentSubgroup;
          return ChoiceChip(
            label: Text('$number'),
            selected: isSelected,
            onSelected: (_) => Navigator.pop(context, number),
            selectedColor: accentColor,
            backgroundColor: backgroundColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : textColor,
            ),
          );
        }).toList(),
      ),
      actions: [
        if (currentSubgroup != null)
          TextButton(
            onPressed: () => Navigator.pop(context, -1),
            child: Text(
              AppLocalizations.of(context)!.remove,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: TextStyle(color: textColor.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }
}