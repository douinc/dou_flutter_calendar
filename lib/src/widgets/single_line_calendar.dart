import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';

class SingleLineCalendar extends StatefulWidget {
  final CalendarViewType viewType;
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? initialSelectedDates;
  final List<CalendarDate>? days;
  final List<CalendarDate> Function(DateTime)? onGenerateDays;
  final double height;
  final double itemWidth;
  final CalendarStyle? style;
  final String? headerDateFormat;

  const SingleLineCalendar({
    super.key,
    required this.viewType,
    required this.initialDate,
    this.onDateSelected,
    this.initialSelectedDates,
    this.days,
    this.onGenerateDays,
    this.height = 60,
    this.itemWidth = 50,
    this.style,
    this.headerDateFormat = 'MM월 dd일',
  });

  @override
  State<SingleLineCalendar> createState() => _SingleLineCalendarState();
}

class _SingleLineCalendarState extends State<SingleLineCalendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _selectedDates;
  final ScrollController _scrollController = ScrollController();
  late List<CalendarDate> _days;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _selectedDates = widget.initialSelectedDates ?? [];
    _initializeDates();
    if (_selectedDates.isEmpty) {
      _selectedDates = [CalendarDate(date: _currentDate)];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateSelected?.call(_currentDate);
        _scrollToSelectedDate();
      });
    }
  }

  void _initializeDates() {
    _startDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    _days = _getDaysInRange(_startDate, _endDate);
  }

  List<CalendarDate> _getDaysInRange(DateTime start, DateTime end) {
    final days = <CalendarDate>[];
    var current = start;

    while (current.isBefore(end)) {
      final firstDayOfMonth = DateTime(current.year, current.month, 1);
      final lastDayOfMonth = DateTime(current.year, current.month + 1, 0);

      final firstWeekday = firstDayOfMonth.weekday;
      for (var i = firstWeekday - 1; i > 0; i--) {
        final previousMonthDay = firstDayOfMonth.subtract(Duration(days: i));
        days.add(CalendarDate(date: previousMonthDay));
      }

      for (var i = 1; i <= lastDayOfMonth.day; i++) {
        final currentDate = DateTime(current.year, current.month, i);
        days.add(CalendarDate(date: currentDate));
      }

      final remainingDays = 42 - (firstWeekday - 1 + lastDayOfMonth.day);
      for (var i = 1; i <= remainingDays; i++) {
        final nextMonthDay = lastDayOfMonth.add(Duration(days: i));
        days.add(CalendarDate(date: nextMonthDay));
      }

      current = DateTime(current.year, current.month + 1, 1);
    }

    return days;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (_selectedDates.isEmpty) return;

    final selectedDate = _selectedDates.first.date;
    final index = _days.indexWhere(
      (day) =>
          day.date.year == selectedDate.year &&
          day.date.month == selectedDate.month &&
          day.date.day == selectedDate.day,
    );

    if (index != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = widget.itemWidth + 8;
      final centerOffset = (screenWidth - itemWidth) / 2;
      final targetOffset = (index * itemWidth) - centerOffset;
      final maxOffset = (_days.length * itemWidth) - screenWidth;
      final clampedOffset = targetOffset.clamp(0.0, maxOffset);

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _selectedDates.isNotEmpty
        ? _selectedDates.first.date
        : _currentDate;

    return Column(
      children: [
        CalendarHeader(
          currentDate: displayDate,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
          dateFormat: 'MM월 dd일',
          showNavigation: false,
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _moveToPreviousDay();
            } else if (details.primaryVelocity! < 0) {
              _moveToNextDay();
            }
          },
          child: SizedBox(
            height: widget.height + 24,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _days.length,
              itemBuilder: (context, dayIndex) {
                final day = _days[dayIndex];
                final weekday = day.date.weekday;
                const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                final isCurrentMonth = day.date.month == displayDate.month;

                return Container(
                  width: widget.itemWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(
                        weekdays[weekday - 1],
                        style:
                            (widget.style?.weekdayTextStyle ??
                                    const TextStyle(fontSize: 12))
                                .copyWith(
                                  color:
                                      (weekday == 7 ? Colors.red : Colors.grey)
                                          .withAlpha(isCurrentMonth ? 255 : 51),
                                ),
                      ),
                      const SizedBox(height: 4),
                      _buildDayItem(day),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(CalendarDate calendarDate) {
    final date = calendarDate.date;
    final isSelected = _selectedDates.any(
      (selected) =>
          selected.date.year == date.year &&
          selected.date.month == date.month &&
          selected.date.day == date.day,
    );
    final isDisabled = calendarDate.isDisabled;
    final isCurrentMonth = date.month == _currentDate.month;

    final style = widget.style ?? const CalendarStyle();
    final selectionColor = style.selectionColor ?? Colors.blue;
    final otherMonthOpacity = style.otherMonthOpacity ?? 0.2;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDates = [calendarDate];
          widget.onDateSelected?.call(date);
          _scrollToSelectedDate();
        });
      },
      child: Container(
        width: widget.itemWidth * 0.7,
        height: widget.itemWidth * 0.7,
        decoration: BoxDecoration(
          color: isSelected ? selectionColor : Colors.grey.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (calendarDate.dateLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Opacity(
                  opacity: isDisabled || !isCurrentMonth
                      ? otherMonthOpacity
                      : 1.0,
                  child: calendarDate.dateLabel!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _moveToNextDay() {
    if (_selectedDates.isEmpty) return;

    final currentIndex = _days.indexWhere(
      (day) =>
          day.date.year == _selectedDates.first.date.year &&
          day.date.month == _selectedDates.first.date.month &&
          day.date.day == _selectedDates.first.date.day,
    );

    if (currentIndex < _days.length - 1) {
      setState(() {
        _selectedDates = [_days[currentIndex + 1]];
        widget.onDateSelected?.call(_days[currentIndex + 1].date);
        _scrollToSelectedDate();
      });
    }
  }

  void _moveToPreviousDay() {
    if (_selectedDates.isEmpty) return;

    final currentIndex = _days.indexWhere(
      (day) =>
          day.date.year == _selectedDates.first.date.year &&
          day.date.month == _selectedDates.first.date.month &&
          day.date.day == _selectedDates.first.date.day,
    );

    if (currentIndex > 0) {
      setState(() {
        _selectedDates = [_days[currentIndex - 1]];
        widget.onDateSelected?.call(_days[currentIndex - 1].date);
        _scrollToSelectedDate();
      });
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _initializeDates();
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _initializeDates();
    });
  }
}
