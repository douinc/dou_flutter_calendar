import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import 'single_line_calendar.dart';
import 'grid_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(List<CalendarDate>)? onDatesSelected;
  final List<CalendarDate>? initialSelectedDates;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final GridCalendarStyle? gridStyle;
  final SingleLineCalendarStyle? singleLineStyle;
  @Deprecated(
    'Use gridStyle for grid calendar and singleLineStyle for single line calendar',
  )
  final GridCalendarStyle? style;
  final String? headerDateFormat;
  final CalendarViewType viewType;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayBuilder;

  const Calendar({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.onDatesSelected,
    this.initialSelectedDates,
    this.multiSelect = false,
    this.days,
    this.gridStyle,
    this.singleLineStyle,
    @Deprecated(
      'Use gridStyle for grid calendar and singleLineStyle for single line calendar',
    )
    this.style,
    this.headerDateFormat,
    this.viewType = CalendarViewType.grid,
    this.locale,
    this.dayBuilder,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewType == CalendarViewType.singleLine) {
      return SingleLineCalendar(
        viewType: widget.viewType,
        initialDate: widget.initialDate ?? DateTime.now(),
        initialSelectedDates: widget.initialSelectedDates,
        onDateSelected: widget.onDateSelected,
        style: widget.singleLineStyle,
        headerDateFormat: widget.headerDateFormat,
        locale: widget.locale,
        dayBuilder: widget.dayBuilder,
      );
    }

    return GridCalendar(
      initialDate: widget.initialDate,
      initialSelectedDates: widget.initialSelectedDates,
      onDateSelected: widget.onDateSelected,
      onDatesSelected: widget.onDatesSelected,
      multiSelect: widget.multiSelect,
      days: widget.days,
      style: widget.gridStyle ?? widget.style,
      headerDateFormat: widget.headerDateFormat,
      locale: widget.locale,
      dayBuilder: widget.dayBuilder,
    );
  }
}
