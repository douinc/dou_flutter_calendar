import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

// Constants for better maintainability
class _CalendarConstants {
  static const double defaultDayWidth = 50.0;
  static const double dateSpacing = 4;
  static const double weekdayPadding = 6.0;
  static const double weekdayToDateSpacing = 4.0;
  static const double bottomPadding = 8.0;
  static const double triangleWidth = 16.0;
  static const double triangleHeight = 14.0;
  static const double topSpacing = 8.0;
  static const int loadThreshold = 10;
  static const int loadDaysCount = 30;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Colors
  static const Color selectedBackgroundColor = Colors.black;
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF71717A);
  static const Color defaultBackgroundColor = Colors.transparent;
  static const Color dayItemBackgroundColor = Color(0x1A808080);

  // Text styles
  static const double defaultWeekdayFontSize = 16.0;
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
  final double dayWidth;
  final SingleLineCalendarStyle? style;
  final String? headerDateFormat;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayBuilder;
  final Widget Function(DateTime currentDate)? headerBuilder;
  final CalendarController? controller;

  const SingleLineCalendar({
    super.key,
    required this.viewType,
    required this.initialDate,
    this.onDateSelected,
    this.initialSelectedDates,
    this.days,
    this.dayWidth = _CalendarConstants.defaultDayWidth,
    this.style,
    this.headerDateFormat,
    this.locale,
    this.dayBuilder,
    this.headerBuilder,
    this.controller,
  });

  @override
  State<SingleLineCalendar> createState() => _SingleLineCalendarState();
}

class _SingleLineCalendarState extends State<SingleLineCalendar>
    with TickerProviderStateMixin {
  late DateTime _currentDate;
  late CalendarDate _selectedDate;
  late List<CalendarDate> _days;
  late List<String> _weekdayNames;
  late double _calculatedHeight;
  PageController? _pageController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  int _currentSelectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoadingDates = false;

  final Map<String, int> _dateIndexMap = {};

  bool _isScrollAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _pageController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller != null && mounted) {
      final newDate = widget.controller!.currentDate;
      final isSelection =
          widget.controller!.lastChangeType == CalendarChangeType.selection;

      if (_currentDate != newDate) {
        _scrollToDate(newDate, callCallback: isSelection);
      }
    }
  }

  @override
  void didUpdateWidget(SingleLineCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);

      if (widget.controller != null) {
        _scrollToDate(widget.controller!.currentDate);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_pageController == null) {
      final double dateSpacing =
          widget.style?.dateSpacing ?? _CalendarConstants.dateSpacing;

      final viewportFraction =
          (widget.dayWidth + (dateSpacing * 2)) /
          MediaQuery.of(context).size.width;

      _pageController = PageController(
        initialPage: _currentSelectedIndex,
        viewportFraction: viewportFraction,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController != null) {
          _scrollToDateAtIndex(_currentSelectedIndex, animate: false);
        }
      });
    }
  }

  void _initializeCalendar() {
    _currentDate = widget.controller?.currentDate ?? widget.initialDate;

    _startDate = DateTime(
      _currentDate.year,
      _currentDate.month - 1,
      _currentDate.day,
    );
    _endDate = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      _currentDate.day,
    );
    _generateDaysInRange();

    final initialDates = widget.initialSelectedDates ?? [];
    _selectedDate = initialDates.isNotEmpty
        ? initialDates.first.copyWith(isSelected: true)
        : CalendarDate(date: _currentDate, isSelected: true);

    _currentSelectedIndex = _findDateIndex(_selectedDate.date);

    if (widget.locale != null) {
      initializeDateFormatting(widget.locale!.languageCode);
    }

    _weekdayNames = DateFormat.EEEE(
      widget.locale?.languageCode,
    ).dateSymbols.STANDALONENARROWWEEKDAYS;

    final weekdayTextStyle = widget.style?.weekdayTextStyle;
    final weekdayHeight =
        (weekdayTextStyle?.fontSize ??
            _CalendarConstants.defaultWeekdayFontSize) +
        _CalendarConstants.weekdayPadding * 2 +
        _CalendarConstants.weekdayPaddingAdjustment;

    final dayItemHeight = widget.dayWidth * _CalendarConstants.dayItemSizeRatio;

    _calculatedHeight =
        weekdayHeight +
        _CalendarConstants.weekdayToDateSpacing +
        dayItemHeight +
        _CalendarConstants.bottomPadding;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDateSelected?.call(_selectedDate.date);
      }
    });

    _isInitialized = true;
  }

  void _generateDaysInRange() {
    final selectedDate = _isInitialized ? _selectedDate.date : _currentDate;
    _days = _getDaysInRange(_startDate, _endDate, selectedDate);
    _rebuildDateIndexMap();
  }

  List<CalendarDate> _getDaysInRange(
    DateTime start,
    DateTime end,
    DateTime? selectedDate,
  ) {
    final days = <CalendarDate>[];
    var current = start;

    while (!current.isAfter(end)) {
      final isSelected =
          selectedDate != null && _isSameDate(current, selectedDate);
      days.add(CalendarDate(date: current, isSelected: isSelected));
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

  int _findDateIndex(DateTime targetDate) {
    final dateKey = _getDateKey(targetDate);
    final index = _dateIndexMap[dateKey];

    if (index != null) {
      return index;
    }

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
      _startDate = DateTime(
        targetDate.year,
        targetDate.month - 1,
        targetDate.day,
      );
      rangeChanged = true;
    }

    if (targetDate.isAfter(_endDate)) {
      _endDate = DateTime(
        targetDate.year,
        targetDate.month + 2,
        targetDate.day,
      );
      rangeChanged = true;
    }

    if (rangeChanged) {
      _generateDaysInRange();
      _currentSelectedIndex = _findDateIndex(_selectedDate.date);
    }
  }

  void _scrollToDate(DateTime targetDate, {bool callCallback = true}) {
    if (!_isInitialized || _isScrollAnimating) return;

    _ensureDateInRange(targetDate);
    final index = _findDateIndex(targetDate);

    setState(() {
      _currentDate = targetDate;
      _currentSelectedIndex = index;
      _selectedDate = CalendarDate(date: targetDate, isSelected: true);
      _updateDaysSelection(targetDate);
    });

    _scrollToDateAtIndex(index, animate: true).then((_) {
      if (mounted) {
        _checkAndLoadMoreDates(index);
      }
    });
  }

  Future<void> _scrollToDateAtIndex(int index, {bool animate = true}) async {
    if (_pageController == null) return;
    if (_isScrollAnimating) return;
    if (mounted) {
      setState(() {
        _isScrollAnimating = true;
      });
    }

    if (animate) {
      await _pageController!.animateToPage(
        index,
        duration: _CalendarConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _pageController!.jumpToPage(index);
    }

    if (mounted) {
      setState(() {
        _isScrollAnimating = false;
      });
    }
  }

  void _checkAndLoadMoreDates(int index) {
    if (_isLoadingDates) return;

    if (index >= _days.length - _CalendarConstants.loadThreshold) {
      _expandDaysForward();
    }

    if (index <= _CalendarConstants.loadThreshold) {
      _expandDaysBackward();
    }
  }

  void _expandDaysForward() {
    if (_isLoadingDates) return;

    setState(() {
      _isLoadingDates = true;
      _endDate = _endDate.add(
        const Duration(days: _CalendarConstants.loadDaysCount),
      );
      _generateDaysInRange();
      _isLoadingDates = false;
    });
  }

  void _expandDaysBackward() {
    if (_isLoadingDates) return;

    final currentSelectedDate = _selectedDate.date;
    final newStartDate = _startDate.subtract(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );

    setState(() {
      _isLoadingDates = true;
      _startDate = newStartDate;
      _generateDaysInRange();
      _currentSelectedIndex = _findDateIndex(currentSelectedDate);
      _isLoadingDates = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController != null) {
        _scrollToDateAtIndex(_currentSelectedIndex, animate: false);
      }
    });
  }

  void _onDateTap(CalendarDate calendarDate) {
    if (_isScrollAnimating) return;

    if (widget.controller != null) {
      widget.controller!.selectDate(calendarDate.date);
    } else {
      _scrollToDate(calendarDate.date);
    }
  }

  void _onPreviousDay() {
    final previousDay = _selectedDate.date.subtract(const Duration(days: 1));
    if (widget.controller != null) {
      widget.controller!.selectDate(previousDay);
    } else {
      _scrollToDate(previousDay);
    }
  }

  void _onNextDay() {
    final nextDay = _selectedDate.date.add(const Duration(days: 1));
    if (widget.controller != null) {
      widget.controller!.selectDate(nextDay);
    } else {
      _scrollToDate(nextDay);
    }
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
    final dateFormatter = widget.headerDateFormat != null
        ? DateFormat(widget.headerDateFormat, widget.locale?.languageCode)
        : DateFormat.MMMd(widget.locale?.languageCode);

    final dateText = dateFormatter.format(displayDate);
    String additionalText = '';

    if (widget.headerDateFormat == null) {
      if (_isToday(displayDate) && _getTodayText() != null) {
        additionalText = '${_getTodayText()}';
      } else if (_isYesterday(displayDate) && _getYesterdayText() != null) {
        additionalText = '${_getYesterdayText()}';
      }
    }

    final fullDateText = dateText + additionalText;

    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(displayDate);
    }

    return CalendarHeader(
      dateText: fullDateText,
      onPrevious: _onPreviousDay,
      onNext: _onNextDay,
      showNavigationButtons: widget.style?.showNavigationButtons ?? true,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDate(date, now);
  }

  bool _isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return _isSameDate(date, yesterday);
  }

  String? _getTodayText() {
    const translations = {
      'en': '(Today)',
      'ko': '(오늘)',
      'ja': '(今日)',
      'zh': '(今天)',
    };
    return translations[widget.locale?.languageCode];
  }

  String? _getYesterdayText() {
    const translations = {
      'en': '(Yesterday)',
      'ko': '(어제)',
      'ja': '(昨日)',
      'zh': '(昨天)',
    };
    return translations[widget.locale?.languageCode];
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
    return Stack(
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
    );
  }

  Widget _buildDateCarousel() {
    return SizedBox(
      height: _calculatedHeight,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          _checkAndLoadMoreDates(_currentSelectedIndex);
          setState(() {
            _selectedDate = _days[_currentSelectedIndex].copyWith(
              isSelected: true,
            );
            _updateDaysSelection(_days[_currentSelectedIndex].date);
          });
          // When scrolling (either user gesture or programmatic animation) ends,
          // notify that the current date has been selected exactly once.
          widget.onDateSelected?.call(_selectedDate.date);
          // Return false so that the notification continues to propagate.

          return false;
        },
        child: IgnorePointer(
          ignoring: _isScrollAnimating,
          child: PageView.builder(
            controller: _pageController!,
            pageSnapping: true,
            onPageChanged: _onPageChanged,
            itemCount: _days.length,
            itemBuilder: (_, index) => _buildDateItem(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, int index) {
    if (index >= _days.length) return const SizedBox.shrink();

    final day = _days[index];
    final isSelected = index == _currentSelectedIndex;
    final dateSpacing =
        widget.style?.dateSpacing ?? _CalendarConstants.dateSpacing;

    return RepaintBoundary(
      child: Container(
        width: widget.dayWidth + (dateSpacing * 2),
        padding: EdgeInsets.symmetric(horizontal: dateSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWeekdayLabel(day.date, isSelected),
            const SizedBox(height: _CalendarConstants.weekdayToDateSpacing),
            Flexible(child: _buildDayItem(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabel(DateTime date, bool isSelected) {
    final weekday = date.weekday;
    final weekdayIndex = weekday == 7 ? 0 : weekday;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(_CalendarConstants.weekdayPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? _CalendarConstants.selectedBackgroundColor
            : _CalendarConstants.defaultBackgroundColor,
      ),
      child: FittedBox(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: _getWeekdayTextStyle(isSelected),
          child: Text(_weekdayNames[weekdayIndex]),
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

  Widget _buildDayItem(CalendarDate calendarDate) {
    if (widget.dayBuilder != null) {
      return GestureDetector(
        onTap: () => _onDateTap(calendarDate),
        child: widget.dayBuilder!(calendarDate),
      );
    }

    return _buildDefaultDayItem(calendarDate);
  }

  Widget _buildDefaultDayItem(CalendarDate calendarDate) {
    final itemSize = widget.dayWidth * _CalendarConstants.dayItemSizeRatio;

    return GestureDetector(
      onTap: () => _onDateTap(calendarDate),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          color: calendarDate.isSelected
              ? _CalendarConstants.selectedBackgroundColor
              : _CalendarConstants.dayItemBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FittedBox(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: _getDayTextStyle(calendarDate.isSelected),
              child: Text(calendarDate.date.day.toString()),
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

  void _updateDaysSelection(DateTime selectedDate) {
    for (int i = 0; i < _days.length; i++) {
      _days[i] = _days[i].copyWith(
        isSelected: _isSameDate(_days[i].date, selectedDate),
      );
    }
  }

  void _onPageChanged(int page) {
    _currentSelectedIndex = page;
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _CalendarConstants.selectedBackgroundColor
      ..style = PaintingStyle.fill;

    const cornerRadius = 4.0;
    final path = Path();

    final tip = Offset(size.width / 2, size.height);
    final topRight = Offset(size.width, 0);
    final topLeft = Offset(0, 0);

    final vecFromTipToTopRight = topRight - tip;
    final distance = vecFromTipToTopRight.distance;
    final pOnRightEdge = tip + (vecFromTipToTopRight / distance) * cornerRadius;

    final vecFromTipToTopLeft = topLeft - tip;
    final pOnLeftEdge = tip + (vecFromTipToTopLeft / distance) * cornerRadius;

    path.moveTo(topLeft.dx, topLeft.dy);
    path.lineTo(topRight.dx, topRight.dy);
    path.lineTo(pOnRightEdge.dx, pOnRightEdge.dy);
    path.quadraticBezierTo(tip.dx, tip.dy, pOnLeftEdge.dx, pOnLeftEdge.dy);
    path.lineTo(topLeft.dx, topLeft.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
