import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';

class CalendarDay extends StatelessWidget {
  final CalendarDate date;
  final Function(DateTime)? onDateSelected;
  final GridCalendarStyle? style;
  final DateTime currentMonth;
  final bool isSelected;
  final Locale? locale;
  final Widget Function(CalendarDate calendarDate)? dayItemBuilder;

  const CalendarDay({
    super.key,
    required this.date,
    required this.currentMonth,
    this.onDateSelected,
    this.style,
    this.isSelected = false,
    this.locale,
    this.dayItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = date.date.month == currentMonth.month;
    final otherMonthOpacity = style?.otherMonthOpacity ?? 0.2;

    final updatedDate = date.copyWith(isSelected: isSelected);

    return GestureDetector(
      onTap: () => onDateSelected?.call(date.date),
      child: dayItemBuilder != null
          ? dayItemBuilder!(updatedDate)
          : Container(
              height: style?.cellHeight ?? 60,
              padding: EdgeInsets.all(style?.cellPadding ?? 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (style?.selectionColor ?? Colors.blue).withAlpha(20)
                    : null,
                borderRadius: BorderRadius.circular(
                  style?.cellBorderRadius ?? 8,
                ),
                border: Border.all(
                  color: isSelected
                      ? style?.selectionColor ?? Colors.blue
                      : Colors.transparent,
                  width: style?.cellBorderWidth ?? 2,
                ),
              ),
              child: Center(
                child: Text(
                  date.date.day.toString(),
                  textAlign: TextAlign.center,
                  style: (style?.dateTextStyle ?? const TextStyle()).copyWith(
                    color: !isCurrentMonth
                        ? (style?.dateTextStyle?.color ?? Colors.black)
                              .withAlpha((255 * otherMonthOpacity).round())
                        : null,
                  ),
                ),
              ),
            ),
    );
  }
}
