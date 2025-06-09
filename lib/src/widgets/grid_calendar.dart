import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../controllers/calendar_controller.dart';
import '../utils/calendar_utils.dart';
import 'calendar_header.dart';
import 'calendar_month.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class GridCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(List<CalendarDate>)? onDatesSelected;
  final List<CalendarDate>? initialSelectedDates;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final GridCalendarStyle? style;
  final String? headerDateFormat;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayBuilder;
  final Widget Function(DateTime currentDate)? headerBuilder;
  final CalendarController? controller;

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
    this.dayBuilder,
    this.headerBuilder,
    this.controller,
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
    _currentDate =
        widget.controller?.currentDate ?? widget.initialDate ?? DateTime.now();
    _selectedDates = widget.initialSelectedDates ?? [];
    _updateDays();

    // Listen to controller changes if provided
    widget.controller?.addListener(_onControllerChanged);

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
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller != null) {
      setState(() {
        _currentDate = widget.controller!.currentDate;
        _updateDays();
      });
    }
  }

  @override
  void didUpdateWidget(GridCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);

      if (widget.controller != null) {
        _currentDate = widget.controller!.currentDate;
        _updateDays();
      }
    }

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
    final newDate = DateTime(_currentDate.year, _currentDate.month - 1);
    if (widget.controller != null) {
      widget.controller!.changeDate(newDate);
    } else {
      setState(() {
        _currentDate = newDate;
        _updateDays();
      });
    }
  }

  void _onNextMonth() {
    final newDate = DateTime(_currentDate.year, _currentDate.month + 1);
    if (widget.controller != null) {
      widget.controller!.changeDate(newDate);
    } else {
      setState(() {
        _currentDate = newDate;
        _updateDays();
      });
    }
  }

  void _onDateSelected(DateTime date) {
    // Update controller if provided
    if (widget.controller != null) {
      widget.controller!.changeDate(date);
    }

    setState(() {
      final calendarDate = CalendarDate(date: date, isSelected: true);
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
        _buildHeader(),
        CalendarMonth(
          days: _days,
          currentMonth: _currentDate,
          onDateSelected: _onDateSelected,
          selectedDates: _selectedDates,
          multiSelect: widget.multiSelect,
          style: widget.style,
          locale: widget.locale,
          dayItemBuilder: widget.dayBuilder,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(_currentDate);
    }

    // Generate dateText for default header
    final dateFormatter = widget.headerDateFormat != null
        ? DateFormat(widget.headerDateFormat, widget.locale?.languageCode)
        : DateFormat.yMMMM(widget.locale?.languageCode);

    final dateText = dateFormatter.format(_currentDate);

    return CalendarHeader(
      dateText: dateText,
      onPreviousMonth: _onPreviousMonth,
      onNextMonth: _onNextMonth,
    );
  }
}
