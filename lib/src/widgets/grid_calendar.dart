import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../utils/calendar_utils.dart';
import 'calendar_header.dart';
import 'calendar_month.dart';
import 'package:intl/date_symbol_data_local.dart';

class GridCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(List<CalendarDate>)? onDatesSelected;
  final List<CalendarDate>? initialSelectedDates;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final CalendarStyle? style;
  final String? headerDateFormat;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate, bool isSelected)?
  dayItemBuilder;

  const GridCalendar({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.onDatesSelected,
    this.initialSelectedDates,
    this.multiSelect = false,
    this.days,
    this.style,
    this.headerDateFormat,
    this.locale,
    this.dayItemBuilder,
  });

  @override
  State<GridCalendar> createState() => _GridCalendarState();
}

class _GridCalendarState extends State<GridCalendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _days;
  late List<CalendarDate> _selectedDates;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _selectedDates = widget.initialSelectedDates ?? [];
    _updateDays();

    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDates.isNotEmpty) {
        widget.onDateSelected?.call(_selectedDates.first.date);
        widget.onDatesSelected?.call(_selectedDates);
      }
    });
  }

  @override
  void didUpdateWidget(GridCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedDates != oldWidget.initialSelectedDates) {
      _selectedDates = widget.initialSelectedDates ?? [];
    }
  }

  void _updateDays() {
    if (widget.days != null) {
      _days = widget.days!;
    } else {
      _days = CalendarUtils.getDaysInMonth(_currentDate);
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _updateDays();
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _updateDays();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      final calendarDate = CalendarDate(date: date);
      if (widget.multiSelect) {
        if (_selectedDates.any((d) => d.date == date)) {
          _selectedDates.removeWhere((d) => d.date == date);
        } else {
          _selectedDates.add(calendarDate);
        }
      } else {
        _selectedDates = [calendarDate];
      }
      widget.onDateSelected?.call(date);
      widget.onDatesSelected?.call(_selectedDates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarHeader(
          currentDate: _currentDate,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
          dateFormat: widget.headerDateFormat,
          locale: widget.locale,
        ),
        CalendarMonth(
          days: _days,
          currentMonth: _currentDate,
          onDateSelected: _onDateSelected,
          selectedDates: _selectedDates,
          multiSelect: widget.multiSelect,
          style: widget.style,
          locale: widget.locale,
          dayItemBuilder: widget.dayItemBuilder,
        ),
      ],
    );
  }
}
