import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../utils/calendar_utils.dart';
import 'calendar_header.dart';
import 'calendar_month.dart';

class Calendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? selectedDates;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final List<CalendarDate> Function(DateTime)? onGenerateDays;
  final CalendarStyle? style;

  const Calendar({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.selectedDates,
    this.multiSelect = false,
    this.days,
    this.onGenerateDays,
    this.style,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _days;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _updateDays();
  }

  void _updateDays() {
    if (widget.days != null) {
      _days = widget.days!;
    } else if (widget.onGenerateDays != null) {
      _days = widget.onGenerateDays!(_currentDate);
      print(
        'Generated days: ${_days.where((day) => day.dateLabel != null).length} days with label',
      );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarHeader(
          currentDate: _currentDate,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
        ),
        CalendarMonth(
          days: _days,
          currentMonth: _currentDate,
          onDateSelected: widget.onDateSelected,
          selectedDates: widget.selectedDates,
          multiSelect: widget.multiSelect,
          style: widget.style,
        ),
      ],
    );
  }
}
