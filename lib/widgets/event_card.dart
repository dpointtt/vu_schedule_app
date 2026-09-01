import 'package:flutter/material.dart';
import 'package:vu_parser/vu_parser.dart';
import 'package:vu_schedule_app/l10n/app_localizations.dart';
import 'package:vu_schedule_app/styles/colors.dart';

class EventCard extends StatelessWidget {
  final ScheduleEvent event;
  final bool isNow;

  const EventCard({
    super.key,
    required this.event,
    this.isNow = false,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNow)
              Container(
                width: 8,
                color: accentColor,
              ),

            SizedBox(
              width: 96,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  8,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (event.className != null ? _formatTime(event.start) : '00:00'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      (event.className != null ? _formatTime(event.end) : '23:59'),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.55),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (isNow) ...[
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.now,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Вертикальный разделитель
            Container(
              width: 1,
              color: textColor.withValues(alpha: 0.1),
            ),

            // Основная информация
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (event.className == null)
                          _Badge(
                            icon: Icons.calendar_month,
                            text: 'Ilsėkitės!',
                          ),

                        if (event.subgroups != null &&
                            event.subgroups!.isNotEmpty)
                          _Badge(
                            icon: Icons.groups_outlined,
                            text: 'Pogrupiai: ${event.subgroups}',
                          ),

                        if (event.types != null &&
                            event.types!.isNotEmpty)
                          _Badge(
                            icon: Icons.school_outlined,
                            text: event.types!,
                          ),
                      ],
                    ),

                    // Преподаватель
                    if (event.professors != null &&
                        event.professors!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.professors!,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Аудитория
                    if (event.classroom != null &&
                        event.classroom!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: textColor.withValues(alpha: 0.7),
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.classroom!,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.75),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.white.withValues(alpha: 0.75),
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'JetBrains Mono',
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}