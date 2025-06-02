import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import 'single_line_calendar.dart';
import 'grid_calendar.dart';

class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(List<CalendarDate>)? onDatesSelected;
  final List<CalendarDate>? initialSelectedDates;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final List<CalendarDate> Function(DateTime)? onGenerateDays;
  final CalendarStyle? style;
  final String? headerDateFormat;
  final CalendarViewType viewType;

  const Calendar({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.onDatesSelected,
    this.initialSelectedDates,
    this.multiSelect = false,
    this.days,
    this.onGenerateDays,
    this.style,
    this.headerDateFormat,
    this.viewType = CalendarViewType.grid,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewType == CalendarViewType.singleLine) {
      return SingleLineCalendar(
        viewType: widget.viewType,
        initialDate: widget.initialDate ?? DateTime.now(),
        initialSelectedDates: widget.initialSelectedDates,
        onDateSelected: widget.onDateSelected,
        onGenerateDays: widget.onGenerateDays,
        style: widget.style,
        headerDateFormat: widget.headerDateFormat,
      );
    }

    return GridCalendar(
      initialDate: widget.initialDate,
      initialSelectedDates: widget.initialSelectedDates,
      onDateSelected: widget.onDateSelected,
      onDatesSelected: widget.onDatesSelected,
      multiSelect: widget.multiSelect,
      days: widget.days,
      onGenerateDays: widget.onGenerateDays,
      style: widget.style,
      headerDateFormat: widget.headerDateFormat,
    );
  }
}
