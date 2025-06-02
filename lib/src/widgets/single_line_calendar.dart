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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animate: false);
    });
  }

  void _initializeDates() {
    // Generate dates for 3 months before and after the current date for smooth scrolling
    _startDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    _days = _getDaysInRange(_startDate, _endDate);
  }

  List<CalendarDate> _getDaysInRange(DateTime start, DateTime end) {
    final days = <CalendarDate>[];
    var current = start;

    // Generate continuous dates from start to end
    while (!current.isAfter(end)) {
      days.add(CalendarDate(date: current));
      current = current.add(const Duration(days: 1));
    }

    // Apply onGenerateDays if provided
    if (widget.onGenerateDays != null) {
      final generatedDays = widget.onGenerateDays!(_currentDate);
      final generatedDaysMap = {
        for (var day in generatedDays)
          '${day.date.year}-${day.date.month}-${day.date.day}': day,
      };

      // Update days with generated data where available
      return days.map((day) {
        final key = '${day.date.year}-${day.date.month}-${day.date.day}';
        return generatedDaysMap[key] ?? day;
      }).toList();
    }

    return days;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate({bool animate = true}) {
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

      if (animate) {
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(clampedOffset);
      }
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
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(height: 1, color: Colors.grey[300]),
                  CustomPaint(
                    size: const Size(20, 10),
                    painter: TrianglePainter(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: List.generate(_days.length, (dayIndex) {
                    final day = _days[dayIndex];
                    final weekday = day.date.weekday;
                    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

                    return Container(
                      width: widget.itemWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day.date.weekday == displayDate.weekday
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                            child: Text(
                              weekdays[weekday - 1],
                              style:
                                  (widget.style?.weekdayTextStyle ??
                                          const TextStyle(fontSize: 10))
                                      .copyWith(
                                        color:
                                            day.date.weekday ==
                                                displayDate.weekday
                                            ? Colors.white
                                            : Color(0xFF71717A),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDayItem(day),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(CalendarDate calendarDate) {
    final date = calendarDate.date;

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
          color: Colors.grey.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Center(child: calendarDate.dateLabel),
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

    // Check if we need to generate more dates
    if (currentIndex >= _days.length - 14) {
      setState(() {
        _endDate = DateTime(_endDate.year, _endDate.month + 1, 1);
        _days = _getDaysInRange(_startDate, _endDate);
      });
    }

    if (currentIndex < _days.length - 1) {
      setState(() {
        _selectedDates = [_days[currentIndex + 1]];
        widget.onDateSelected?.call(_days[currentIndex + 1].date);
        _scrollToSelectedDate(animate: true);
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

    // Check if we need to generate more dates
    if (currentIndex <= 14) {
      setState(() {
        _startDate = DateTime(_startDate.year, _startDate.month - 1, 1);
        _days = _getDaysInRange(_startDate, _endDate);
      });
    }

    if (currentIndex > 0) {
      setState(() {
        _selectedDates = [_days[currentIndex - 1]];
        widget.onDateSelected?.call(_days[currentIndex - 1].date);
        _scrollToSelectedDate(animate: true);
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
