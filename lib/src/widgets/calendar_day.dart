import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../models/calendar_style.dart';

class CalendarDay extends StatelessWidget {
  final CalendarDate date;
  final Function(DateTime)? onDateSelected;
  final CalendarStyle? style;
  final Widget Function(
    BuildContext context,
    DateTime date,
    bool isSelected,
    bool isWeekend,
  )?
  dateBuilder;
  final Widget Function(
    BuildContext context,
    Widget dateLabel,
    bool isSelected,
  )?
  dateLabelBuilder;
  final DateTime currentMonth;

  const CalendarDay({
    super.key,
    required this.date,
    required this.currentMonth,
    this.onDateSelected,
    this.style,
    this.dateBuilder,
    this.dateLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = date.isSelected;
    final isWeekend =
        date.date.weekday == DateTime.saturday ||
        date.date.weekday == DateTime.sunday;
    final isCurrentMonth = date.date.month == currentMonth.month;
    final otherMonthOpacity = style?.otherMonthOpacity ?? 0.2;

    Widget dateWidget = Text(
      date.date.day.toString(),
      textAlign: TextAlign.center,
      style: (style?.dateTextStyle ?? const TextStyle()).copyWith(
        color: isSelected
            ? Colors.black
            : !isCurrentMonth
            ? (style?.dateTextStyle?.color ?? Colors.black).withAlpha(
                (255 * otherMonthOpacity).round(),
              )
            : null,
      ),
    );

    if (dateBuilder != null) {
      dateWidget = dateBuilder!(context, date.date, isSelected, isWeekend);
    }

    Widget? labelWidget;
    if (date.dateLabel != null) {
      labelWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Opacity(
          opacity: !isCurrentMonth ? otherMonthOpacity : 1.0,
          child: date.dateLabel!,
        ),
      );

      if (dateLabelBuilder != null) {
        labelWidget = dateLabelBuilder!(context, labelWidget, isSelected);
      }
    }

    return GestureDetector(
      onTap: () => onDateSelected?.call(date.date),
      child: Container(
        height: style?.cellHeight ?? 60,
        padding: EdgeInsets.all(style?.cellPadding ?? 4),
        decoration: BoxDecoration(
          color: null,
          borderRadius: BorderRadius.circular(style?.cellBorderRadius ?? 8),
          border: Border.all(
            color: isSelected
                ? style?.selectionColor ?? Colors.blue
                : Colors.transparent,
            width: style?.cellBorderWidth ?? 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: const EdgeInsets.only(top: 6), child: dateWidget),
            if (labelWidget != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: labelWidget,
              ),
          ],
        ),
      ),
    );
  }
}
