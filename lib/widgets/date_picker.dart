import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vu_schedule_app/l10n/app_localizations.dart';

import '../styles/colors.dart';

class DatePicker extends StatefulWidget {
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isNext;

  const DatePicker({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
    required this.isNext,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  DateTime? _oldDate;
  DateTime? _newDate;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentDate == widget.currentDate) {
      return;
    }

    _oldDate = oldWidget.currentDate;
    _newDate = widget.currentDate;

    _isAnimating = true;

    _controller.forward(from: 0).then((_) {
      if (!mounted) return;

      setState(() {
        _isAnimating = false;
        _oldDate = null;
        _newDate = null;
      });
    });

    setState(() {});
  }

  Future<void> _selectDateFromCalendar(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.currentDate,
      firstDate: DateTime(DateTime.now().year-5),
      lastDate: DateTime(DateTime.now().year+5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentColor,
              onPrimary: textColor,
              surface: backgroundColor,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: textColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != widget.currentDate) {
      widget.onDateChanged(pickedDate);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', AppLocalizations.of(context)!.dateLocale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 40,
      child: ClipRect(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _selectDateFromCalendar(context),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (!_isAnimating ||
                  _oldDate == null ||
                  _newDate == null) {
                return Center(
                  child: Text(
                    _formatDate(widget.currentDate),
                    maxLines: 1,
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final progress = Curves.easeInOut.transform(
                _controller.value,
              );

              final direction = widget.isNext ? 1.0 : -1.0;

              // Новая дата:
              // next  -> приходит справа
              // back  -> приходит слева
              final newOffset = Offset(
                direction * (1 - progress),
                0,
              );

              // Старая дата:
              // next  -> уезжает влево
              // back  -> уезжает вправо
              final oldOffset = Offset(
                -direction * progress,
                0,
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: oldOffset * 180,
                    child: Text(
                      _formatDate(_oldDate!),
                      maxLines: 1,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: newOffset * 180,
                    child: Text(
                      _formatDate(_newDate!),
                      maxLines: 1,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}