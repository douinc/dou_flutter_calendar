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
  final Function(DateTime)? onMonthChanged;
  final bool multiSelect;
  final List<CalendarDate>? days;
  final GridCalendarStyle? style;
  final String? headerDateFormat;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayBuilder;
  final Widget Function(DateTime currentDate)? headerBuilder;
  final CalendarController? controller;
  final bool enableSwipe;

  const GridCalendar({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.onDatesSelected,
    this.initialSelectedDates,
    this.onMonthChanged,
    this.multiSelect = false,
    this.days,
    this.style,
    this.headerDateFormat,
    this.locale,
    this.dayBuilder,
    this.headerBuilder,
    this.controller,
    this.enableSwipe = true,
  });

  @override
  State<GridCalendar> createState() => _GridCalendarState();
}

class _GridCalendarState extends State<GridCalendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _selectedDates;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentDate =
        widget.controller?.currentDate ?? widget.initialDate ?? DateTime.now();

    _pageController = PageController(initialPage: _calculateInitialPage());

    // If no initial selected dates provided, default to current date
    if (widget.initialSelectedDates == null ||
        widget.initialSelectedDates!.isEmpty) {
      if (widget.multiSelect) {
        _selectedDates = [];
      } else {
        _selectedDates = [CalendarDate(date: _currentDate, isSelected: true)];
      }
    } else {
      _selectedDates = widget.initialSelectedDates!;
    }

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
    _pageController.dispose();
    super.dispose();
  }

  int _calculateInitialPage() {
    return (_currentDate.year * 12) + _currentDate.month - 1;
  }

  void _onControllerChanged() {
    if (widget.controller != null) {
      final newDate = widget.controller!.currentDate;
      final isSelection =
          widget.controller!.lastChangeType == CalendarChangeType.selection;

      if (!isSelection) {
        final targetPage = (newDate.year * 12) + newDate.month - 1;
        if (_pageController.hasClients &&
            _pageController.page?.round() != targetPage) {
          _pageController.jumpToPage(targetPage);
        }
      }

      setState(() {
        _currentDate = newDate;

        if (isSelection) {
          final calendarDate = CalendarDate(date: newDate, isSelected: true);
          if (widget.multiSelect) {
            if (!_selectedDates.any((d) => _isSameDate(d.date, newDate))) {
              _selectedDates.add(calendarDate);
            }
          } else {
            _selectedDates = [calendarDate];
          }
        }
      });

      if (isSelection) {
        widget.onDateSelected?.call(newDate);
        widget.onDatesSelected?.call(_selectedDates);
      }
    }
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
        _pageController.jumpToPage(_calculateInitialPage());
      }
    }

    if (widget.initialSelectedDates != oldWidget.initialSelectedDates) {
      // If no initial selected dates provided, default to current date
      if (widget.initialSelectedDates == null ||
          widget.initialSelectedDates!.isEmpty) {
        if (widget.multiSelect) {
          _selectedDates = [];
        } else {
          _selectedDates = [CalendarDate(date: _currentDate, isSelected: true)];
        }
      } else {
        _selectedDates = widget.initialSelectedDates!;
      }
    }
  }

  void _onPreviousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onDateSelected(DateTime date) {
    if (date.month != _currentDate.month || date.year != _currentDate.year) {
      final targetPage = (date.year * 12) + date.month - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetPage);
      }
    }
    // Update controller if provided
    if (widget.controller != null) {
      widget.controller!.selectDate(date);
    } else {
      setState(() {
        final calendarDate = CalendarDate(date: date, isSelected: true);
        if (widget.multiSelect) {
          if (_selectedDates.any((d) => _isSameDate(d.date, date))) {
            _selectedDates.removeWhere((d) => _isSameDate(d.date, date));
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildPageView()]);
  }

  Widget _buildPageView() {
    final calendarHeight = widget.style?.calendarHeight ?? 440.0;

    return SizedBox(
      height: calendarHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          final year = pageIndex ~/ 12;
          final month = (pageIndex % 12) + 1;
          final newDate = DateTime(year, month, 1);
          if (widget.controller != null) {
            widget.controller!.navigateToDate(newDate);
          } else {
            setState(() {
              _currentDate = newDate;
            });
          }
          widget.onMonthChanged?.call(newDate);
        },
        itemBuilder: (context, pageIndex) {
          final year = pageIndex ~/ 12;
          final month = (pageIndex % 12) + 1;
          final dateForPage = DateTime(year, month, 1);

          final days = CalendarUtils.getDaysInMonth(dateForPage);

          return CalendarMonth(
            days: days,
            currentMonth: dateForPage,
            onDateSelected: _onDateSelected,
            selectedDates: _selectedDates,
            multiSelect: widget.multiSelect,
            style: widget.style,
            locale: widget.locale,
            dayItemBuilder: widget.dayBuilder,
          );
        },
      ),
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
      onPrevious: _onPreviousMonth,
      onNext: _onNextMonth,
      showNavigationButtons: widget.style?.showNavigationButtons ?? true,
    );
  }
}
