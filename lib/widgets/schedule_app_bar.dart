import 'package:flutter/material.dart';
import 'package:vu_schedule_app/widgets/date_picker.dart';

import '../styles/colors.dart';

class ScheduleAppBar extends StatelessWidget {
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;

  final bool isNext;

  final bool showOnlyMine;
  final VoidCallback onToggleFilter;

  final VoidCallback onSettingsButtonPressed;

  final String groupLabel;

  const ScheduleAppBar({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
    required this.isNext,
    required this.showOnlyMine,
    required this.onToggleFilter,
    required this.onSettingsButtonPressed,
    required this.groupLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 68,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DatePicker(
                      currentDate: currentDate,
                      onDateChanged: onDateChanged,
                      isNext: isNext,
                    ),
                    Text(
                      // "$faculty (${program.substring(0, 3)}.) ${course}k. ${group}gr.",
                      groupLabel,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onSettingsButtonPressed,
                  iconSize: 32,
                  icon: const Icon(Icons.settings_suggest_rounded),
                  color: textColor,
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onToggleFilter,
                  style: TextButton.styleFrom(
                    backgroundColor: showOnlyMine
                        ? secondaryColor
                        : textColor.withValues(alpha: 0.1),
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(24),
                      side: BorderSide(
                        color: textColor.withValues(alpha: (showOnlyMine ? 0 : 0.3)),
                        width: showOnlyMine ? 0 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    showOnlyMine ? "MANO" : "VISI",
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}