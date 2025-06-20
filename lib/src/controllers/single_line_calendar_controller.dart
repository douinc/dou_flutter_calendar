import 'package:flutter/material.dart';
import '../models/calendar_enums.dart';

/// Controller for managing SingleLineCalendar state programmatically
class SingleLineCalendarController extends ChangeNotifier {
  DateTime _currentDate;
  CalendarChangeType _lastChangeType = CalendarChangeType.selection;

  SingleLineCalendarController({DateTime? initialDate})
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
}
