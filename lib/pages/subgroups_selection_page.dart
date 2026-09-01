import 'package:flutter/material.dart';
import 'package:vu_parser/vu_parser.dart';
import 'package:vu_schedule_app/styles/colors.dart';

import '../l10n/app_localizations.dart';
import '../storage/storage_service.dart';

class SubgroupsSelectionPage extends StatefulWidget {
  final List<ScheduleEvent> events;

  const SubgroupsSelectionPage({
    super.key,
    required this.events,
  });

  @override
  State<SubgroupsSelectionPage> createState() =>
      _SubgroupsSelectionPageState();
}

class _SubgroupsSelectionPageState extends State<SubgroupsSelectionPage> {
  Map<String, int> subgroups = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubgroups();
  }

  Future<void> _loadSubgroups() async {
    final saved = await StorageService.getSubgroups();

    if (!mounted) return;

    setState(() {
      subgroups = Map<String, int>.from(saved);
      _isLoading = false;
    });
  }

  Future<void> _openSubgroupDialog(ScheduleEvent event) async {
    final className = event.className;
    if (className == null) return;

    final currentSubgroup = subgroups[className];

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return _SubgroupDialog(
          event: event,
          className: className,
          currentSubgroup: currentSubgroup,
        );
      },
    );

    if (result == null) return;

    final parsedSubgroup = int.tryParse(result.trim());

    if (parsedSubgroup != null) {
      subgroups[className] = parsedSubgroup;
    } else {
      subgroups.remove(className);
    }

    await StorageService.setSubgroups(subgroups);

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.events.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context)!.subgroupsSelectionEmpty,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final event = widget.events[index];
          final className = event.className;

          if (className == null) return const SizedBox.shrink();

          final selectedSubgroup = subgroups[className];

          return Material(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openSubgroupDialog(event),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            className,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
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

class _SubgroupDialog extends StatefulWidget {
  final ScheduleEvent event;
  final String className;
  final int? currentSubgroup;

  const _SubgroupDialog({
    required this.event,
    required this.className,
    required this.currentSubgroup,
  });

  @override
  State<_SubgroupDialog> createState() => _SubgroupDialogState();
}

class _SubgroupDialogState extends State<_SubgroupDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.currentSubgroup?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Text(
        widget.event.title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.subgroupNumber,
                labelStyle: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                ),
                hintText: AppLocalizations.of(context)!.subgroupNumber,
                hintStyle: TextStyle(
                  color: textColor.withValues(alpha: 0.3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: textColor.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.currentSubgroup != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context, '');
            },
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: Text(
            AppLocalizations.of(context)!.save,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}