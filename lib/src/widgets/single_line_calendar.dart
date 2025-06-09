import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Constants for better maintainability
class _CalendarConstants {
  static const double defaultHeight = 60.0;
  static const double defaultItemWidth = 50.0;
  static const double viewportFraction = 0.15;
  static const double horizontalMargin = 2.5;
  static const double weekdayPadding = 6.0;
  static const double itemSpacing = 4.0;
  static const double bottomPadding = 8.0;
  static const double triangleWidth = 20.0;
  static const double triangleHeight = 10.0;
  static const double separatorHeight = 11.0;
  static const double topSpacing = 10.0;
  static const int loadThreshold = 10;
  static const int loadDaysCount = 30;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Colors
  static const Color selectedBackgroundColor = Colors.black;
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF71717A);
  static const Color defaultBackgroundColor = Colors.transparent;
}

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
    this.height = _CalendarConstants.defaultHeight,
    this.itemWidth = _CalendarConstants.defaultItemWidth,
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
  late CalendarDate _selectedDate;
  late PageController _pageController;
  late List<CalendarDate> _days;
  late List<String> _weekdayNames;
  late double _calculatedHeight;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  void _initializeCalendar() {
    _currentDate = widget.initialDate;
    final initialDates = widget.initialSelectedDates ?? [];
    _selectedDate = initialDates.isNotEmpty
        ? initialDates.first
        : CalendarDate(date: _currentDate);

    _initializeDates();
    _initializeLocalization();
    _initializeWeekdayNames();
    _calculateHeight();
    _initializeSelectedDates();
    _initializePageController();

    _scheduleInitialCallback();
  }

  void _initializeDates() {
    _startDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    _days = _getDaysInRange(_startDate, _endDate);
  }

  void _initializeLocalization() {
    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }
  }

  void _initializeWeekdayNames() {
    _weekdayNames = DateFormat.EEEE().dateSymbols.STANDALONENARROWWEEKDAYS;
  }

  void _calculateHeight() {
    final weekdayHeight =
        (widget.style?.weekdayTextStyle?.fontSize ?? 10) +
        _CalendarConstants.weekdayPadding * 2 +
        6;
    final dayItemHeight = widget.itemWidth * 0.7;

    _calculatedHeight =
        weekdayHeight +
        _CalendarConstants.itemSpacing +
        dayItemHeight +
        _CalendarConstants.bottomPadding;
  }

  void _initializeSelectedDates() {
    _currentPageIndex = _findDateIndex(_selectedDate.date);
  }

  void _initializePageController() {
    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: _CalendarConstants.viewportFraction,
    );
  }

  void _scheduleInitialCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected?.call(_selectedDate.date);
    });
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

  int _findDateIndex(DateTime targetDate) {
    final index = _days.indexWhere((day) => _isSameDate(day.date, targetDate));
    return index == -1 ? 0 : index;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToDate(DateTime targetDate, {bool animate = true}) {
    final index = _findDateIndex(targetDate);

    setState(() {
      _currentPageIndex = index;
    });

    if (animate) {
      _pageController.animateToPage(
        index,
        duration: _CalendarConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _selectedDate.date;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildHeader(displayDate), _buildCalendarBody()],
    );
  }

  Widget _buildHeader(DateTime displayDate) {
    return CalendarHeader(
      currentDate: _currentDate,
      selectedDate: displayDate,
      dateFormat: widget.headerDateFormat,
      showNavigation: false,
      isSingleLine: true,
      locale: widget.locale,
    );
  }

  Widget _buildCalendarBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTriangleIndicator(),
        SizedBox(height: _CalendarConstants.topSpacing),
        _buildDateCarousel(),
      ],
    );
  }

  Widget _buildTriangleIndicator() {
    return SizedBox(
      width: double.infinity,
      height: _CalendarConstants.separatorHeight,
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(
                _CalendarConstants.triangleWidth,
                _CalendarConstants.triangleHeight,
              ),
              painter: _TrianglePainter(),
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
    );
  }

  Widget _buildDateCarousel() {
    return SizedBox(
      height: _calculatedHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemCount: _days.length,
        itemBuilder: _buildDateItem,
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, int index) {
    final day = _days[index];
    final isSelected = index == _currentPageIndex;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _CalendarConstants.horizontalMargin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWeekdayLabel(day.date, isSelected),
          const SizedBox(height: _CalendarConstants.itemSpacing),
          Flexible(child: _buildDayItem(day, isSelected)),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabel(DateTime date, bool isSelected) {
    final weekday = date.weekday;

    return Container(
      padding: const EdgeInsets.all(_CalendarConstants.weekdayPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? _CalendarConstants.selectedBackgroundColor
            : _CalendarConstants.defaultBackgroundColor,
      ),
      child: FittedBox(
        child: Text(
          _weekdayNames[weekday - 1],
          style: _getWeekdayTextStyle(isSelected),
        ),
      ),
    );
  }

  TextStyle _getWeekdayTextStyle(bool isSelected) {
    return (widget.style?.weekdayTextStyle ?? const TextStyle(fontSize: 10))
        .copyWith(
          color: isSelected
              ? _CalendarConstants.selectedTextColor
              : _CalendarConstants.unselectedTextColor,
        );
  }

  Widget _buildDayItem(CalendarDate calendarDate, bool isSelected) {
    if (widget.dayItemBuilder != null) {
      return GestureDetector(
        onTap: () => _onDateTap(calendarDate),
        child: widget.dayItemBuilder!(calendarDate, isSelected),
      );
    }

    return _buildDefaultDayItem(calendarDate, isSelected);
  }

  Widget _buildDefaultDayItem(CalendarDate calendarDate, bool isSelected) {
    final itemSize = widget.itemWidth * 0.7;

    return GestureDetector(
      onTap: () => _onDateTap(calendarDate),
      child: Container(
        width: itemSize,
        height: itemSize,
        constraints: BoxConstraints(
          minWidth: 30,
          minHeight: 30,
          maxWidth: widget.itemWidth,
          maxHeight: widget.itemWidth,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _CalendarConstants.selectedBackgroundColor
              : Colors.grey.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              calendarDate.date.day.toString(),
              style: _getDayTextStyle(isSelected),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _getDayTextStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? _CalendarConstants.selectedTextColor : Colors.black,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );
  }

  void _handlePageChanged(int index) {
    if (index != _currentPageIndex) {
      _updateSelectedDate(index);
      _checkAndLoadMoreDates(index);
    }
  }

  void _checkAndLoadMoreDates(int index) {
    // Load more dates when approaching the end
    if (index >= _days.length - _CalendarConstants.loadThreshold) {
      _expandDaysForward();
    }

    // Load more dates when approaching the beginning
    if (index <= _CalendarConstants.loadThreshold) {
      _expandDaysBackward();
    }
  }

  void _expandDaysForward() {
    setState(() {
      _endDate = _endDate.add(
        const Duration(days: _CalendarConstants.loadDaysCount),
      );
      _days = _getDaysInRange(_startDate, _endDate);
    });
  }

  void _expandDaysBackward() {
    final newStartDate = _startDate.subtract(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );
    final newDays = _getDaysInRange(newStartDate, _endDate);
    final addedDaysCount = newDays.length - _days.length;

    setState(() {
      _startDate = newStartDate;
      _days = newDays;
      _currentPageIndex += addedDaysCount;
    });

    // PageController의 페이지도 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentPageIndex);
    });
  }

  void _updateSelectedDate(int index) {
    setState(() {
      _currentPageIndex = index;
      _selectedDate = _days[index];
    });
    widget.onDateSelected?.call(_days[index].date);
  }

  void _onDateTap(CalendarDate calendarDate) {
    final index = _findDateIndex(calendarDate.date);
    _updateSelectedDate(index);
    _scrollToDate(calendarDate.date);
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _CalendarConstants.selectedBackgroundColor
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
