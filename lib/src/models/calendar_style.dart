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
    );
  }
}

class SingleLineCalendarStyle {
  final TextStyle? weekdayTextStyle;
  final double? dateSpacing;

  const SingleLineCalendarStyle({this.weekdayTextStyle, this.dateSpacing});

  SingleLineCalendarStyle copyWith({
    TextStyle? weekdayTextStyle,
    double? dateSpacing,
  }) {
    return SingleLineCalendarStyle(
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      dateSpacing: dateSpacing ?? this.dateSpacing,
    );
  }
}

// 기존 CalendarStyle은 호환성을 위해 GridCalendarStyle의 alias로 유지
@Deprecated('Use GridCalendarStyle instead')
typedef CalendarStyle = GridCalendarStyle;

enum CalendarViewType { singleLine, grid }
