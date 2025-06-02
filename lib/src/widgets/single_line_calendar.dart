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
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _selectedDates = widget.initialSelectedDates ?? [];
    if (_selectedDates.isEmpty) {
      _selectedDates = [CalendarDate(date: _currentDate)];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateSelected?.call(_currentDate);
        _scrollToSelectedDate();
      });
    }
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (_selectedDates.isEmpty) return;

    final selectedDate = _selectedDates.first.date;
    final days = _getDaysInMonth(_currentDate);
    final index = days.indexWhere(
      (day) =>
          day.date.year == selectedDate.year &&
          day.date.month == selectedDate.month &&
          day.date.day == selectedDate.day,
    );

    if (index != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = widget.itemWidth + 8; // itemWidth + margin
      final totalWidth = days.length * itemWidth;
      final centerOffset = (screenWidth - itemWidth) / 2;

      // 선택된 날짜가 가운데 오도록 스크롤 위치 계산
      final targetOffset = (index * itemWidth) - centerOffset;

      // 스크롤 범위 제한
      final maxOffset = totalWidth - screenWidth;
      final clampedOffset = targetOffset.clamp(0.0, maxOffset);

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<CalendarDate> _getDaysInMonth(DateTime date) {
    if (widget.days != null) {
      return widget.days!;
    } else if (widget.onGenerateDays != null) {
      return widget.onGenerateDays!(date);
    } else {
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

      // 이전 달의 마지막 날짜들
      final previousMonthDays = <CalendarDate>[];
      final firstWeekday = firstDayOfMonth.weekday;
      for (var i = firstWeekday - 1; i > 0; i--) {
        final previousMonthDay = firstDayOfMonth.subtract(Duration(days: i));
        previousMonthDays.add(CalendarDate(date: previousMonthDay));
      }

      // 현재 달의 날짜들
      final currentMonthDays = <CalendarDate>[];
      for (var i = 1; i <= lastDayOfMonth.day; i++) {
        final currentDate = DateTime(date.year, date.month, i);
        currentMonthDays.add(CalendarDate(date: currentDate));
      }

      // 다음 달의 날짜들
      final nextMonthDays = <CalendarDate>[];
      final remainingDays =
          42 - (previousMonthDays.length + currentMonthDays.length);
      for (var i = 1; i <= remainingDays; i++) {
        final nextMonthDay = lastDayOfMonth.add(Duration(days: i));
        nextMonthDays.add(CalendarDate(date: nextMonthDay));
      }

      return [...previousMonthDays, ...currentMonthDays, ...nextMonthDays];
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
        SizedBox(
          height: widget.height + 24,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentDate = DateTime(
                  _currentDate.year,
                  _currentDate.month + index,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSelectedDate();
                });
              });
            },
            itemBuilder: (context, index) {
              final days = _getDaysInMonth(_currentDate);
              return ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, dayIndex) {
                  final day = days[dayIndex];
                  final weekday = day.date.weekday;
                  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
                  final isCurrentMonth = day.date.month == _currentDate.month;
                  final otherMonthOpacity =
                      widget.style?.otherMonthOpacity ?? 0.2;

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
                                        (weekday == 7
                                                ? Colors.red
                                                : Colors.grey)
                                            .withAlpha(
                                              isCurrentMonth ? 255 : 51,
                                            ),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        _buildDayItem(day),
                      ],
                    ),
                  );
                },
              );
            },
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

  void _onPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }
}
