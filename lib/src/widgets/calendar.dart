import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../utils/calendar_utils.dart';
import 'calendar_header.dart';
import 'calendar_month.dart';

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
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _days;
  late List<CalendarDate> _selectedDates;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _selectedDates = widget.initialSelectedDates ?? [];
    if (widget.initialDate != null && _selectedDates.isEmpty) {
      _selectedDates = [CalendarDate(date: widget.initialDate!)];
    }
    _updateDays();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDates.isNotEmpty) {
        widget.onDateSelected?.call(_selectedDates.first.date);
        widget.onDatesSelected?.call(_selectedDates);
      }
    });
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedDates != oldWidget.initialSelectedDates) {
      _selectedDates = widget.initialSelectedDates ?? [];
    }
  }

  void _updateDays() {
    if (widget.days != null) {
      _days = widget.days!;
    } else if (widget.onGenerateDays != null) {
      _days = widget.onGenerateDays!(_currentDate);
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
        ),
        CalendarMonth(
          days: _days,
          currentMonth: _currentDate,
          onDateSelected: _onDateSelected,
          selectedDates: _selectedDates,
          multiSelect: widget.multiSelect,
          style: widget.style,
        ),
      ],
    );
  }
}
