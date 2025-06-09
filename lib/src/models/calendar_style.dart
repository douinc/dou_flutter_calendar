import 'package:flutter/material.dart';

class CalendarStyle {
  final Color? selectionColor;
  final TextStyle? dateTextStyle;
  final TextStyle? weekdayTextStyle;
  final Color? todayBackgroundColor;
  final double? cellHeight;
  final double? cellPadding;
  final double? cellBorderRadius;
  final double? cellBorderWidth;
  final double? rowSpacing;
  final double? otherMonthOpacity;
  final double? dateSpacing;

  const CalendarStyle({
    this.selectionColor,
    this.dateTextStyle,
    this.weekdayTextStyle,
    this.todayBackgroundColor,
    this.cellHeight,
    this.cellPadding,
    this.cellBorderRadius,
    this.cellBorderWidth,
    this.rowSpacing,
    this.otherMonthOpacity,
    this.dateSpacing,
  });

  CalendarStyle copyWith({
    Color? selectionColor,
    TextStyle? dateTextStyle,
    TextStyle? weekdayTextStyle,
    Color? todayBackgroundColor,
    double? cellHeight,
    double? cellPadding,
    double? cellBorderRadius,
    double? cellBorderWidth,
    double? rowSpacing,
    double? otherMonthOpacity,
    double? dateSpacing,
  }) {
    return CalendarStyle(
      selectionColor: selectionColor ?? this.selectionColor,
      dateTextStyle: dateTextStyle ?? this.dateTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      cellHeight: cellHeight ?? this.cellHeight,
      cellPadding: cellPadding ?? this.cellPadding,
      cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
      cellBorderWidth: cellBorderWidth ?? this.cellBorderWidth,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      otherMonthOpacity: otherMonthOpacity ?? this.otherMonthOpacity,
      dateSpacing: dateSpacing ?? this.dateSpacing,
    );
  }
}

enum CalendarViewType { singleLine, grid }
