import 'package:flutter/material.dart';
import 'package:vu_schedule_app/l10n/app_localizations.dart';
import 'package:vu_schedule_app/styles/colors.dart';

class BreakDivider extends StatelessWidget {
  final Duration duration;
  final bool isNow;

  const BreakDivider({
    super.key,
    required this.duration,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes;

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              indent: 16,
              endIndent: 16,
              color: (isNow ? accentColor.withValues(alpha: 0.5) : textColor.withValues(alpha: 0.1)),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: (isNow ? accentColor : backgroundColor),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: textColor.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              '$minutes ${AppLocalizations.of(context)!.minBreak}',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Divider(
              indent: 16,
              endIndent: 16,
              color: (isNow ? accentColor.withValues(alpha: 0.5) : textColor.withValues(alpha: 0.1)),
            ),
          ),
        ],
      ),
    );
  }
}