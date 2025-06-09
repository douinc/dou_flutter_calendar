import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import 'calendar_day.dart';

class CalendarWeek extends StatelessWidget {
  final List<CalendarDate> days;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? selectedDates;
  final bool multiSelect;
  final GridCalendarStyle? style;
  final DateTime currentMonth;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayItemBuilder;

  const CalendarWeek({
    super.key,
    required this.days,
    required this.currentMonth,
    this.onDateSelected,
    this.selectedDates,
    this.multiSelect = false,
    this.style,
    this.locale,
    this.dayItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: style?.rowSpacing ?? 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          final isSelected =
              selectedDates?.any(
                (selected) =>
                    selected.date.year == day.date.year &&
                    selected.date.month == day.date.month &&
                    selected.date.day == day.date.day,
              ) ??
              false;

          return Flexible(
            child: CalendarDay(
              date: day,
              currentMonth: currentMonth,
              onDateSelected: onDateSelected,
              style: style,
              isSelected: isSelected,
              locale: locale,
              dayItemBuilder: dayItemBuilder,
            ),
          );
        }).toList(),
      ),
    );
  }
}
