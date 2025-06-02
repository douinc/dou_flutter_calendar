import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../utils/calendar_utils.dart';
import 'calendar_week.dart';

class CalendarMonth extends StatelessWidget {
  final List<CalendarDate> days;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? selectedDates;
  final bool multiSelect;
  final CalendarStyle? style;
  final DateTime currentMonth;

  const CalendarMonth({
    super.key,
    required this.days,
    required this.currentMonth,
    this.onDateSelected,
    this.selectedDates,
    this.multiSelect = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: CalendarUtils.getWeekdayNames().map((weekday) {
            return Expanded(
              child: Center(
                child: Text(weekday, style: style?.weekdayTextStyle),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate(6, (weekIndex) {
          final weekDays = days.skip(weekIndex * 7).take(7).toList();
          return CalendarWeek(
            days: weekDays,
            currentMonth: currentMonth,
            onDateSelected: onDateSelected,
            selectedDates: selectedDates,
            multiSelect: multiSelect,
            style: style,
          );
        }),
      ],
    );
  }
}
