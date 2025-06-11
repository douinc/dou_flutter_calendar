import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';
import '../controllers/calendar_controller.dart';
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
  final String? headerDateFormat;
  final CalendarViewType viewType;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayBuilder;
  final Widget Function(DateTime currentDate)? headerBuilder;
  final CalendarController? controller;
  final bool enableSwipe;

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
    this.headerDateFormat,
    this.viewType = CalendarViewType.grid,
    this.locale,
    this.dayBuilder,
    this.headerBuilder,
    this.controller,
    this.enableSwipe = true,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late CalendarController _internalController;
  CalendarController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();

    // Create internal controller if none provided
    _internalController = CalendarController(initialDate: widget.initialDate);

    // Listen to controller changes
    _controller.addListener(_onControllerChanged);

    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    // Only dispose internal controller, not the external one
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {
      // Trigger rebuild when controller date changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = _controller.currentDate;

    if (widget.viewType == CalendarViewType.singleLine) {
      return SingleLineCalendar(
        viewType: widget.viewType,
        initialDate: currentDate,
        initialSelectedDates: widget.initialSelectedDates,
        onDateSelected: widget.onDateSelected,
        style: widget.singleLineStyle,
        headerDateFormat: widget.headerDateFormat,
        locale: widget.locale,
        dayBuilder: widget.dayBuilder,
        headerBuilder: widget.headerBuilder,
        controller: _controller,
      );
    }

    return GridCalendar(
      initialDate: currentDate,
      initialSelectedDates: widget.initialSelectedDates,
      onDateSelected: widget.onDateSelected,
      onDatesSelected: widget.onDatesSelected,
      multiSelect: widget.multiSelect,
      days: widget.days,
      style: widget.gridStyle,
      headerDateFormat: widget.headerDateFormat,
      locale: widget.locale,
      dayBuilder: widget.dayBuilder,
      headerBuilder: widget.headerBuilder,
      controller: _controller,
      enableSwipe: widget.enableSwipe,
    );
  }
}
