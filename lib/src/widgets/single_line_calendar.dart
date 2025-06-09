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
  static const double triangleWidth = 15.0;
  static const double triangleHeight = 10.0;
  static const double separatorHeight = 11.0;
  static const double topSpacing = 10.0;
  static const int loadThreshold = 10;
  static const int loadDaysCount = 30;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double scrollSensitivity = 0.6; // Reduce scroll sensitivity
  static const double selectionThreshold = 0.25; // Date selection sensitivity

  // Colors
  static const Color selectedBackgroundColor = Colors.black;
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF71717A);
  static const Color defaultBackgroundColor = Colors.transparent;
  static const Color separatorColor = Color(0xFFE5E5E5);
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
  final Widget Function(String dateText)? headerBuilder;

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
  });

  @override
  State<SingleLineCalendar> createState() => _SingleLineCalendarState();
}

class _SingleLineCalendarState extends State<SingleLineCalendar>
    with TickerProviderStateMixin {
  late DateTime _currentDate;
  late CalendarDate _selectedDate;
  late ScrollController _scrollController;
  late List<CalendarDate> _days;
  late List<String> _weekdayNames;
  late double _calculatedHeight;
  late AnimationController _animationController;

  // Date range management
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // State management
  int _currentSelectedIndex = 0;
  bool _isScrolling = false;
  bool _isInitialized = false;
  bool _isProgrammaticScroll = false;
  bool _isLoadingDates = false; // Add loading state for date expansion

  // Gesture handling
  double _startPanOffset = 0.0;
  double _lastPanOffset = 0.0;
  bool _isPanGestureActive = false;

  // Scroll state detection
  bool _userScrollInProgress = false;
  bool _pendingCallbackAfterScroll = false;

  // Performance optimization - date index mapping
  final Map<String, int> _dateIndexMap = {};

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
    _initializeScrollController();
    _initializeAnimationController();
    _scheduleInitialCallback();
    _isInitialized = true;
  }

  void _initializeSelectedDate() {
    final initialDates = widget.initialSelectedDates ?? [];
    _selectedDate = initialDates.isNotEmpty
        ? initialDates.first.copyWith(isSelected: true)
        : CalendarDate(date: _currentDate, isSelected: true);
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

    final dayItemHeight = widget.dayWidth * _CalendarConstants.dayItemSizeRatio;

    _calculatedHeight =
        weekdayHeight +
        _CalendarConstants.weekdayToDateSpacing +
        dayItemHeight +
        _CalendarConstants.bottomPadding;
  }

  void _initializeScrollController() {
    _currentSelectedIndex = _findDateIndex(_selectedDate.date);
    _scrollController = ScrollController();

    // Add listener to detect scroll position changes
    _scrollController.addListener(_onScrollChanged);

    // Schedule initial scroll to selected date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollToDateAtIndex(_currentSelectedIndex, animate: false);
      }
    });
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: _CalendarConstants.animationDuration,
      vsync: this,
    );
  }

  void _onScrollChanged() {
    if (_isProgrammaticScroll || !_scrollController.hasClients) return;

    // Don't update selection during snap animation, pan gesture, or date loading
    if (_isScrolling || _isPanGestureActive || _isLoadingDates) return;

    final position = _scrollController.position;

    // Detect if user scroll is in progress (only when not in pan gesture)
    final isScrollingNow = position.isScrollingNotifier.value;

    if (isScrollingNow && !_userScrollInProgress) {
      // Scroll started
      _userScrollInProgress = true;
      _pendingCallbackAfterScroll = false;
    } else if (!isScrollingNow && _userScrollInProgress) {
      // Scroll ended
      _userScrollInProgress = false;
      if (_pendingCallbackAfterScroll && mounted) {
        // Ensure selected date is centered and call callback
        _scrollToDateAtIndex(_currentSelectedIndex, animate: true).then((_) {
          if (mounted) {
            widget.onDateSelected?.call(_selectedDate.date);
          }
        });
        _pendingCallbackAfterScroll = false;
      }
    }

    // Calculate which item is closest to center with sensitive threshold
    final viewportWidth = position.viewportDimension;
    final scrollOffset = position.pixels;
    final centerOffset = scrollOffset + (viewportWidth / 2);

    final centerIndex = _calculateDateIndexFromOffset(centerOffset);

    if (centerIndex != _currentSelectedIndex && centerIndex < _days.length) {
      setState(() {
        _currentSelectedIndex = centerIndex;
        _selectedDate = _days[centerIndex].copyWith(isSelected: true);
        _updateDaysSelection(centerIndex);
      });

      _checkAndLoadMoreDates(centerIndex);

      // Mark that we have a pending callback if scroll is in progress
      if (_userScrollInProgress) {
        _pendingCallbackAfterScroll = true;
      } else if (!_isScrolling && mounted) {
        // If not scrolling, call immediately with correct date
        widget.onDateSelected?.call(_selectedDate.date);
      }
    }
  }

  double _getItemTotalWidth() {
    final dateSpacing =
        widget.style?.dateSpacing ?? _CalendarConstants.dateSpacing;
    return widget.dayWidth + (dateSpacing * 2);
  }

  /// Calculate the target date index based on scroll position and sensitivity threshold
  int _calculateDateIndexFromOffset(double centerOffset) {
    final itemTotalWidth = _getItemTotalWidth();
    final rawIndex = centerOffset / itemTotalWidth;
    final floorIndex = rawIndex.floor();
    final remainder = rawIndex - floorIndex;

    int targetIndex;
    if (remainder < _CalendarConstants.selectionThreshold) {
      // In the first 25% of current item, select previous
      targetIndex = floorIndex - 1;
    } else if (remainder > (1 - _CalendarConstants.selectionThreshold)) {
      // In the last 25% of current item, select next
      targetIndex = floorIndex + 1;
    } else {
      // In the middle 50%, stay with current item
      targetIndex = floorIndex;
    }

    return targetIndex.clamp(0, _days.length - 1);
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
      final isSelected = _isSameDate(current, _selectedDate.date);
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
      _currentSelectedIndex = _findDateIndex(_selectedDate.date);
    }
  }

  void _scrollToDate(DateTime targetDate) {
    if (!_isInitialized) return;

    _ensureDateInRange(targetDate);
    final index = _findDateIndex(targetDate);

    setState(() {
      _currentSelectedIndex = index;
      _selectedDate = CalendarDate(date: targetDate, isSelected: true);
      _updateDaysSelection(index);
      _isScrolling = true;
    });

    _scrollToDateAtIndex(index, animate: true).then((_) {
      if (mounted) {
        setState(() {
          _isScrolling = false;
        });

        // Check and load more dates after scroll animation completes
        _checkAndLoadMoreDates(index);

        // Call onDateSelected after programmatic scroll completes
        widget.onDateSelected?.call(_selectedDate.date);
      }
    });
  }

  Future<void> _scrollToDateAtIndex(int index, {bool animate = true}) async {
    if (!_scrollController.hasClients) return;

    final itemTotalWidth = _getItemTotalWidth();
    final viewportWidth = _scrollController.position.viewportDimension;
    // Use itemTotalWidth / 2 instead of widget.itemWidth / 2 to account for dateSpacing
    final targetOffset =
        (index * itemTotalWidth) - (viewportWidth / 2) + (itemTotalWidth / 2);

    final clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _isProgrammaticScroll = true;

    if (animate) {
      await _scrollController.animateTo(
        clampedOffset,
        duration: _CalendarConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }

    _isProgrammaticScroll = false;
  }

  void _updateDaysSelection(int selectedIndex) {
    for (int i = 0; i < _days.length; i++) {
      _days[i] = _days[i].copyWith(isSelected: i == selectedIndex);
    }
  }

  void _checkAndLoadMoreDates(int index) {
    // Prevent multiple simultaneous loading operations
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

    _isLoadingDates = true;

    final newEndDate = _endDate.add(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );

    // Generate new days without immediately calling setState
    final newDays = _getDaysInRange(_startDate, newEndDate);

    // Use microtask to avoid immediate UI update during scroll
    Future.microtask(() {
      if (mounted && !_isScrolling && !_isPanGestureActive) {
        setState(() {
          _endDate = newEndDate;
          _days = newDays;
          _rebuildDateIndexMap();
          _isLoadingDates = false;
        });
      } else {
        // Defer update until scroll/pan gesture completes
        _scheduleDelayedUpdate(() {
          if (mounted) {
            setState(() {
              _endDate = newEndDate;
              _days = newDays;
              _rebuildDateIndexMap();
              _isLoadingDates = false;
            });
          }
        });
      }
    });
  }

  void _expandDaysBackward() {
    if (_isLoadingDates) return;

    _isLoadingDates = true;

    final currentSelectedDate = _selectedDate.date;
    final newStartDate = _startDate.subtract(
      const Duration(days: _CalendarConstants.loadDaysCount),
    );

    // Generate new days without immediately calling setState
    final newDays = _getDaysInRange(newStartDate, _endDate);
    final newSelectedIndex = _findDateIndexInList(currentSelectedDate, newDays);

    // Use microtask to avoid immediate UI update during scroll
    Future.microtask(() {
      if (mounted && !_isScrolling && !_isPanGestureActive) {
        setState(() {
          _startDate = newStartDate;
          _days = newDays;
          _currentSelectedIndex = newSelectedIndex;
          _rebuildDateIndexMap();
          _isLoadingDates = false;
        });

        // Schedule scroll position adjustment without animation to prevent flicker
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollToDateAtIndex(_currentSelectedIndex, animate: false);
          }
        });
      } else {
        // Defer update until scroll/pan gesture completes
        _scheduleDelayedUpdate(() {
          if (mounted) {
            setState(() {
              _startDate = newStartDate;
              _days = newDays;
              _currentSelectedIndex = newSelectedIndex;
              _rebuildDateIndexMap();
              _isLoadingDates = false;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                _scrollToDateAtIndex(_currentSelectedIndex, animate: false);
              }
            });
          }
        });
      }
    });
  }

  // Helper method to schedule delayed updates
  void _scheduleDelayedUpdate(VoidCallback callback) {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isScrolling && !_isPanGestureActive) {
        timer.cancel();
        callback();
      }
    });
  }

  // Helper method to find date index in a specific list
  int _findDateIndexInList(DateTime targetDate, List<CalendarDate> daysList) {
    for (int i = 0; i < daysList.length; i++) {
      if (_isSameDate(daysList[i].date, targetDate)) {
        return i;
      }
    }
    return 0;
  }

  void _onDateTap(CalendarDate calendarDate) {
    _scrollToDate(calendarDate.date);
  }

  // MARK: - Gesture Handling

  /// Handle pan gesture start - initialize pan state and stop animations
  void _onPanStart(DragStartDetails details) {
    _startPanOffset = details.globalPosition.dx;
    _lastPanOffset = _startPanOffset;
    _animationController.stop();

    // Mark that pan gesture is active
    _isPanGestureActive = true;
    _userScrollInProgress = false;
    _pendingCallbackAfterScroll = false;
  }

  /// Handle pan gesture update - scroll content based on finger movement
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_scrollController.hasClients) return;

    final currentOffset = details.globalPosition.dx;
    final deltaX =
        (_lastPanOffset - currentOffset) * _CalendarConstants.scrollSensitivity;

    _lastPanOffset = currentOffset;

    final newScrollOffset = _scrollController.offset + deltaX;
    final clampedOffset = newScrollOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.jumpTo(clampedOffset);
  }

  /// Handle pan gesture end - snap to nearest date and update selection
  void _onPanEnd(DragEndDetails details) {
    if (!_scrollController.hasClients) return;

    // Calculate nearest date for snapping using same logic as selection
    final viewportWidth = _scrollController.position.viewportDimension;
    final centerOffset = _scrollController.offset + (viewportWidth / 2);
    final nearestIndex = _calculateDateIndexFromOffset(centerOffset);

    // Start snap animation without changing selection state yet
    setState(() {
      _isScrolling = true;
    });

    _scrollToDateAtIndex(nearestIndex, animate: true).then((_) {
      if (mounted) {
        // Update all state after snap animation completes
        setState(() {
          _isScrolling = false;
          _currentSelectedIndex = nearestIndex;
          _selectedDate = _days[nearestIndex].copyWith(isSelected: true);
          _updateDaysSelection(nearestIndex);
        });

        // Mark pan gesture and scroll as ended
        _isPanGestureActive = false;
        _userScrollInProgress = false;
        _pendingCallbackAfterScroll = false;

        // Check and load more dates after snap animation completes
        _checkAndLoadMoreDates(nearestIndex);

        // Call onDateSelected after snap animation and state update completes
        widget.onDateSelected?.call(_selectedDate.date);
      }
    });
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
    // Generate dateText with common logic
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
      return widget.headerBuilder!(fullDateText);
    }

    return CalendarHeader(dateText: fullDateText);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
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
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics:
              const NeverScrollableScrollPhysics(), // Disable default scrolling
          itemCount: _days.length,
          itemBuilder: (context, index) => _buildDateItem(context, index),
          // Add caching for better performance
          cacheExtent: MediaQuery.of(context).size.width * 2,
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
    final weekdayIndex = weekday == 7 ? 0 : weekday; // Adjust Sunday index

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

    return _buildDefaultDayItem(calendarDate, calendarDate.isSelected);
  }

  Widget _buildDefaultDayItem(CalendarDate calendarDate, bool isSelected) {
    final itemSize = widget.dayWidth * _CalendarConstants.dayItemSizeRatio;

    return GestureDetector(
      onTap: () => _onDateTap(calendarDate),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
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
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: _getDayTextStyle(isSelected),
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
