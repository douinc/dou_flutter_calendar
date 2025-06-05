import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer';

class SingleLineCalendar extends StatefulWidget {
  final CalendarViewType viewType;
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;
  final List<CalendarDate>? initialSelectedDates;
  final List<CalendarDate>? days;
  final double height;
  final double itemWidth;
  final CalendarStyle? style;
  final String? headerDateFormat;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate, bool isSelected)?
  dayItemBuilder;

  const SingleLineCalendar({
    super.key,
    required this.viewType,
    required this.initialDate,
    this.onDateSelected,
    this.initialSelectedDates,
    this.days,
    this.height = 60,
    this.itemWidth = 50,
    this.style,
    this.headerDateFormat,
    this.locale,
    this.dayItemBuilder,
  });

  @override
  State<SingleLineCalendar> createState() => _SingleLineCalendarState();
}

class _SingleLineCalendarState extends State<SingleLineCalendar> {
  late DateTime _currentDate;
  late List<CalendarDate> _selectedDates;
  late PageController _pageController;
  late List<CalendarDate> _days;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _selectedDates = widget.initialSelectedDates ?? [];
    _initializeDates();

    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }

    if (_selectedDates.isEmpty) {
      _selectedDates = [CalendarDate(date: _currentDate)];
    }

    _currentPageIndex = _days.indexWhere(
      (day) => _isSameDate(day.date, _selectedDates.first.date),
    );
    if (_currentPageIndex == -1) _currentPageIndex = 0;

    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: 0.15,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected?.call(_selectedDates.first.date);
    });
  }

  void _initializeDates() {
    _startDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    _days = _getDaysInRange(_startDate, _endDate);
  }

  List<CalendarDate> _getDaysInRange(DateTime start, DateTime end) {
    final days = <CalendarDate>[];
    var current = start;

    while (!current.isAfter(end)) {
      days.add(CalendarDate(date: current));
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 동적 높이 계산
  double _calculateDynamicHeight() {
    // 요일 텍스트 높이 + 패딩
    final weekdayHeight =
        (widget.style?.weekdayTextStyle?.fontSize ?? 10) + 12 + 6; // 텍스트 + 패딩

    // 날짜 아이템 높이
    final dayItemHeight = widget.itemWidth * 0.7;

    // 사이 간격
    final spacing = 4.0;

    // 여유 공간 (하단 패딩)
    final bottomPadding = 8.0;

    return weekdayHeight + spacing + dayItemHeight + bottomPadding;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToDate(DateTime targetDate, {bool animate = true}) {
    final index = _days.indexWhere((day) => _isSameDate(day.date, targetDate));

    if (index != -1) {
      setState(() {
        _currentPageIndex = index;
      });
      if (animate) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _selectedDates.isNotEmpty
        ? _selectedDates.first.date
        : _currentDate;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHeader(
          currentDate: _currentDate,
          selectedDate: displayDate,
          dateFormat: widget.headerDateFormat,
          showNavigation: false,
          isSingleLine: true,
          locale: widget.locale,
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _moveToPreviousDay();
            } else if (details.primaryVelocity! < 0) {
              _moveToNextDay();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 11,
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 1, color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: _calculateDynamicHeight(),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    log(_currentPageIndex.toString());
                    if (index != _currentPageIndex) {
                      setState(() {
                        _currentPageIndex = index;
                        _selectedDates = [_days[index]];
                      });
                      widget.onDateSelected?.call(_days[index].date);
                    }
                  },
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    final weekday = day.date.weekday;
                    final weekdays =
                        DateFormat.EEEE().dateSymbols.STANDALONENARROWWEEKDAYS;
                    final isSelected = index == _currentPageIndex;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                            child: FittedBox(
                              child: Text(
                                weekdays[weekday - 1],
                                style:
                                    (widget.style?.weekdayTextStyle ??
                                            const TextStyle(fontSize: 10))
                                        .copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : Color(0xFF71717A),
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 날짜 표시
                          Flexible(child: _buildDayItem(day, isSelected)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(CalendarDate calendarDate, bool isSelected) {
    final date = calendarDate.date;

    if (widget.dayItemBuilder != null) {
      return GestureDetector(
        onTap: () => _onDateTap(calendarDate),
        child: widget.dayItemBuilder!(calendarDate, isSelected),
      );
    }

    return GestureDetector(
      onTap: () => _onDateTap(calendarDate),
      child: Container(
        width: widget.itemWidth * 0.7,
        height: widget.itemWidth * 0.7,
        constraints: BoxConstraints(
          minWidth: 30,
          minHeight: 30,
          maxWidth: widget.itemWidth,
          maxHeight: widget.itemWidth,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDateTap(CalendarDate calendarDate) {
    _scrollToDate(calendarDate.date);
  }

  void _moveToNextDay() {
    if (_currentPageIndex < _days.length - 1) {
      if (_currentPageIndex >= _days.length - 10) {
        setState(() {
          _endDate = _endDate.add(const Duration(days: 30));
          _days = _getDaysInRange(_startDate, _endDate);
        });
      }

      setState(() {
        _currentPageIndex++;
        _selectedDates = [_days[_currentPageIndex]];
      });
      widget.onDateSelected?.call(_days[_currentPageIndex].date);

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _moveToPreviousDay() {
    if (_currentPageIndex > 0) {
      if (_currentPageIndex <= 10) {
        final newStartDate = _startDate.subtract(const Duration(days: 30));
        final newDays = _getDaysInRange(newStartDate, _endDate);
        final addedDaysCount = newDays.length - _days.length;

        setState(() {
          _startDate = newStartDate;
          _days = newDays;
          _currentPageIndex += addedDaysCount;
        });
      }

      setState(() {
        _currentPageIndex--;
        _selectedDates = [_days[_currentPageIndex]];
      });
      widget.onDateSelected?.call(_days[_currentPageIndex].date);

      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
