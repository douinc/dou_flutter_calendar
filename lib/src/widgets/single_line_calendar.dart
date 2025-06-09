import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Constants for better maintainability
class _CalendarConstants {
  static const double defaultHeight = 60.0;
  static const double defaultItemWidth = 50.0;
  static const double viewportFraction = 0.13;
  static const double horizontalMargin = 2.5;
  static const double weekdayPadding = 6.0;
  static const double itemSpacing = 4.0;
  static const double bottomPadding = 8.0;
  static const double triangleWidth = 15.0;
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
  static const Color separatorColor = Color(0xFFE5E5E5);
  static const Color dayItemBackgroundColor = Color(0x1A808080);

  // Text styles
  static const double defaultWeekdayFontSize = 10.0;
  static const double defaultDayFontSize = 14.0;
  static const double weekdayPaddingAdjustment = 6.0;
  static const double dayItemSizeRatio = 0.7;
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

  // Date range management
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // State management
  int _currentPageIndex = 0;
  bool _isScrolling = false;
  bool _isInitialized = false;

  // Performance optimization - date index mapping
  final Map<String, int> _dateIndexMap = {};

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // MARK: - Initialization Methods

  void _initializeCalendar() {
    _currentDate = widget.initialDate;
    _initializeSelectedDate();
    _initializeDateRange();
    _initializeLocalization();
    _initializeWeekdayNames();
    _calculateHeight();
    _initializePageController();
    _scheduleInitialCallback();
    _isInitialized = true;
  }

  void _initializeSelectedDate() {
    final initialDates = widget.initialSelectedDates ?? [];
    _selectedDate = initialDates.isNotEmpty
        ? initialDates.first
        : CalendarDate(date: _currentDate);
  }

  void _initializeDateRange() {
    _startDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    _generateDaysInRange();
  }

  void _initializeLocalization() {
    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }
  }

  void _initializeWeekdayNames() {
    _weekdayNames = DateFormat.EEEE(
      widget.locale?.languageCode,
    ).dateSymbols.STANDALONENARROWWEEKDAYS;
  }

  void _calculateHeight() {
    final weekdayTextStyle = widget.style?.weekdayTextStyle;
    final weekdayHeight =
        (weekdayTextStyle?.fontSize ??
            _CalendarConstants.defaultWeekdayFontSize) +
        _CalendarConstants.weekdayPadding * 2 +
        _CalendarConstants.weekdayPaddingAdjustment;

    final dayItemHeight =
        widget.itemWidth * _CalendarConstants.dayItemSizeRatio;

    _calculatedHeight =
        weekdayHeight +
        _CalendarConstants.itemSpacing +
        dayItemHeight +
        _CalendarConstants.bottomPadding;
  }

  void _initializePageController() {
    _currentPageIndex = _findDateIndex(_selectedDate.date);
    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: _CalendarConstants.viewportFraction,
    );
  }

  void _scheduleInitialCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDateSelected?.call(_selectedDate.date);
      }
    });
  }

  void _generateDaysInRange() {
    _days = _getDaysInRange(_startDate, _endDate);
    _rebuildDateIndexMap();
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

  void _rebuildDateIndexMap() {
    _dateIndexMap.clear();
    for (int i = 0; i < _days.length; i++) {
      final dateKey = _getDateKey(_days[i].date);
      _dateIndexMap[dateKey] = i;
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Optimized date index finder using Map lookup instead of linear search
  int _findDateIndex(DateTime targetDate) {
    final dateKey = _getDateKey(targetDate);
    final index = _dateIndexMap[dateKey];

    if (index != null) {
      return index;
    }

    // Fallback to linear search if map lookup fails
    final fallbackIndex = _days.indexWhere(
      (day) => _isSameDate(day.date, targetDate),
    );

    if (fallbackIndex != -1) {
      _dateIndexMap[dateKey] = fallbackIndex;
      return fallbackIndex;
    }

    return 0;
  }

  void _ensureDateInRange(DateTime targetDate) {
    bool rangeChanged = false;

    if (targetDate.isBefore(_startDate)) {
      _startDate = DateTime(targetDate.year, targetDate.month - 1, 1);
      rangeChanged = true;
    }

    if (targetDate.isAfter(_endDate)) {
      _endDate = DateTime(targetDate.year, targetDate.month + 1, 0);
      rangeChanged = true;
    }

    if (rangeChanged) {
      _generateDaysInRange();
      _currentPageIndex = _findDateIndex(_selectedDate.date);
    }
  }

  void _scrollToDate(DateTime targetDate) {
    if (!_isInitialized) return;

    _ensureDateInRange(targetDate);
    final index = _findDateIndex(targetDate);

    setState(() {
      _currentPageIndex = index;
      _selectedDate = CalendarDate(date: targetDate);
      _isScrolling = true;
    });

    _pageController
        .animateToPage(
          index,
          duration: _CalendarConstants.animationDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (mounted) {
            setState(() {
              _isScrolling = false;
            });

            final finalIndex = _findDateIndex(targetDate);
            if (finalIndex < _days.length) {
              widget.onDateSelected?.call(_days[finalIndex].date);
            }
          }
        });
  }

  void _handlePageChanged(int index) {
    if (index == _currentPageIndex || index >= _days.length) return;

    setState(() {
      _currentPageIndex = index;
      _selectedDate = _days[index];
    });

    if (!_isScrolling && mounted) {
      widget.onDateSelected?.call(_days[index].date);
    }

    _checkAndLoadMoreDates(index);
  }

  void _checkAndLoadMoreDates(int index) {
    if (index >= _days.length - _CalendarConstants.loadThreshold) {
      _expandDaysForward();
    }

    if (index <= _CalendarConstants.loadThreshold) {
      _expandDaysBackward();
    }
  }

  void _expandDaysForward() {
    final newEndDate = _endDate.add(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );

    setState(() {
      _endDate = newEndDate;
      _generateDaysInRange();
    });
  }

  void _expandDaysBackward() {
    final currentSelectedDate = _selectedDate.date;
    final newStartDate = _startDate.subtract(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );

    setState(() {
      _startDate = newStartDate;
      _generateDaysInRange();
      _currentPageIndex = _findDateIndex(currentSelectedDate);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(_currentPageIndex);
      }
    });
  }

  void _onDateTap(CalendarDate calendarDate) {
    _scrollToDate(calendarDate.date);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildHeader(_selectedDate.date), _buildCalendarBody()],
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
        const SizedBox(height: _CalendarConstants.topSpacing),
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
            child: Container(
              height: 1,
              color: _CalendarConstants.separatorColor,
            ),
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
    if (index >= _days.length) return const SizedBox.shrink();

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
    final weekdayIndex = weekday == 7 ? 0 : weekday; // Adjust Sunday index

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
          _weekdayNames[weekdayIndex],
          style: _getWeekdayTextStyle(isSelected),
        ),
      ),
    );
  }

  TextStyle _getWeekdayTextStyle(bool isSelected) {
    final baseStyle =
        widget.style?.weekdayTextStyle ??
        const TextStyle(fontSize: _CalendarConstants.defaultWeekdayFontSize);

    return baseStyle.copyWith(
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
    final itemSize = widget.itemWidth * _CalendarConstants.dayItemSizeRatio;

    return GestureDetector(
      onTap: () => _onDateTap(calendarDate),
      child: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          color: isSelected
              ? _CalendarConstants.selectedBackgroundColor
              : _CalendarConstants.dayItemBackgroundColor,
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
      fontSize: _CalendarConstants.defaultDayFontSize,
    );
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
