import 'package:flutter/material.dart';

class GridCalendarStyle {
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
  final bool? showNavigationButtons;
  final double? calendarHeight;

  const GridCalendarStyle({
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
    this.showNavigationButtons,
    this.calendarHeight,
  });

  GridCalendarStyle copyWith({
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
    bool? showNavigationButtons,
    double? calendarHeight,
  }) {
    return GridCalendarStyle(
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
      showNavigationButtons:
          showNavigationButtons ?? this.showNavigationButtons,
      calendarHeight: calendarHeight ?? this.calendarHeight,
    );
  }
}

class SingleLineCalendarStyle {
  final TextStyle? weekdayTextStyle;
  final double? dateSpacing;
  final bool? showNavigationButtons;

  const SingleLineCalendarStyle({
    this.weekdayTextStyle,
    this.dateSpacing,
    this.showNavigationButtons,
  });

  SingleLineCalendarStyle copyWith({
    TextStyle? weekdayTextStyle,
    double? dateSpacing,
    bool? showNavigationButtons,
  }) {
    return SingleLineCalendarStyle(
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      dateSpacing: dateSpacing ?? this.dateSpacing,
      showNavigationButtons:
          showNavigationButtons ?? this.showNavigationButtons,
    );
  }
}
