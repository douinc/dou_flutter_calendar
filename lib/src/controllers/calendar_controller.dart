import 'package:flutter/material.dart';

/// Enum to define the type of calendar change
enum CalendarChangeType {
  selection, // Date was selected (should trigger callbacks)
  navigation, // View was navigated (should not trigger callbacks)
}

/// Controller for managing Calendar state programmatically
class CalendarController extends ChangeNotifier {
  DateTime _currentDate;
  CalendarChangeType _lastChangeType = CalendarChangeType.selection;

  CalendarController({DateTime? initialDate})
    : _currentDate = initialDate ?? DateTime.now();

  /// Current selected date
  DateTime get currentDate => _currentDate;

  /// Type of the last change made
  CalendarChangeType get lastChangeType => _lastChangeType;

  /// Select a specific date programmatically (triggers selection callbacks)
  void selectDate(DateTime newDate) {
    if (_currentDate != newDate) {
      _currentDate = newDate;
      _lastChangeType = CalendarChangeType.selection;
      notifyListeners();
    }
  }

  /// Navigate to a specific date without triggering selection (view navigation only)
  void navigateToDate(DateTime newDate) {
    if (_currentDate != newDate) {
      _currentDate = newDate;
      _lastChangeType = CalendarChangeType.navigation;
      notifyListeners();
    }
  }

  /// Move to next month (navigation only, doesn't trigger selection)
  void nextMonth() {
    final nextMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    final targetDay = _currentDate.day;
    final daysInNextMonth = DateTime(
      nextMonth.year,
      nextMonth.month + 1,
      0,
    ).day;
    final safeDay = targetDay > daysInNextMonth ? daysInNextMonth : targetDay;

    navigateToDate(DateTime(nextMonth.year, nextMonth.month, safeDay));
  }

  /// Move to previous month (navigation only, doesn't trigger selection)
  void previousMonth() {
    final prevMonth = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    final targetDay = _currentDate.day;
    final daysInPrevMonth = DateTime(
      prevMonth.year,
      prevMonth.month + 1,
      0,
    ).day;
    final safeDay = targetDay > daysInPrevMonth ? daysInPrevMonth : targetDay;

    navigateToDate(DateTime(prevMonth.year, prevMonth.month, safeDay));
  }

  /// Move to next day (selection with callbacks)
  void nextDay() {
    selectDate(_currentDate.add(const Duration(days: 1)));
  }

  /// Move to previous day (selection with callbacks)
  void previousDay() {
    selectDate(_currentDate.subtract(const Duration(days: 1)));
  }

  /// Move to today (selection with callbacks)
  void goToToday() {
    selectDate(DateTime.now());
  }

  /// Move to specific year, month, day (selection with callbacks)
  void goToDate(int year, int month, int day) {
    selectDate(DateTime(year, month, day));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
