import 'package:flutter/material.dart';

/// Controller for managing Calendar state programmatically
class CalendarController extends ChangeNotifier {
  DateTime _currentDate;

  CalendarController({DateTime? initialDate})
    : _currentDate = initialDate ?? DateTime.now();

  /// Current selected date
  DateTime get currentDate => _currentDate;

  /// Change the current date programmatically
  void changeDate(DateTime newDate) {
    if (_currentDate != newDate) {
      _currentDate = newDate;
      notifyListeners();
    }
  }

  /// Move to next month
  void nextMonth() {
    changeDate(
      DateTime(_currentDate.year, _currentDate.month + 1, _currentDate.day),
    );
  }

  /// Move to previous month
  void previousMonth() {
    changeDate(
      DateTime(_currentDate.year, _currentDate.month - 1, _currentDate.day),
    );
  }

  /// Move to next day
  void nextDay() {
    changeDate(_currentDate.add(const Duration(days: 1)));
  }

  /// Move to previous day
  void previousDay() {
    changeDate(_currentDate.subtract(const Duration(days: 1)));
  }

  /// Move to today
  void goToToday() {
    changeDate(DateTime.now());
  }

  /// Move to specific year, month, day
  void goToDate(int year, int month, int day) {
    changeDate(DateTime(year, month, day));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
