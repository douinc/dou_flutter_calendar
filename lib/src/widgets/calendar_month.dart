import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../utils/calendar_utils.dart';
import 'calendar_week.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarMonth extends StatelessWidget {
  final List<CalendarDate> days;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? selectedDates;
  final bool multiSelect;
  final CalendarStyle? style;
  final DateTime currentMonth;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate, bool isSelected)?
  dayItemBuilder;

  const CalendarMonth({
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
    if (locale != null) {
      initializeDateFormatting(locale!.languageCode);
    }
    return Column(
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: CalendarUtils.getWeekdayNames(locale?.languageCode).map((
            weekday,
          ) {
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
            locale: locale,
            dayItemBuilder: dayItemBuilder,
          );
        }),
      ],
    );
  }
}
