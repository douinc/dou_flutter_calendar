import 'package:flutter/material.dart';

class CalendarDate {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final Widget? dateLabel;

  const CalendarDate({
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isDisabled = false,
    this.dateLabel,
  });

  CalendarDate copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isToday,
    bool? isDisabled,
    Widget? dateLabel,
  }) {
    return CalendarDate(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
      isDisabled: isDisabled ?? this.isDisabled,
      dateLabel: dateLabel ?? this.dateLabel,
    );
  }
}
