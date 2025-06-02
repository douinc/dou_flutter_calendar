import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/message_lookup_by_library.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final DateTime? selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final String? dateFormat;
  final bool showNavigation;
  final bool isSingleLine;
  final Locale? locale;

  const CalendarHeader({
    super.key,
    required this.currentDate,
    this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.dateFormat,
    this.showNavigation = true,
    this.isSingleLine = false,
    this.locale,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String? _getTodayText() {
    const translations = {
      'en': '(Today)',
      'ko': '(오늘)',
      'ja': '(今日)',
      'zh': '(今天)',
    };
    return translations[locale?.languageCode];
  }

  @override
  Widget build(BuildContext context) {
    if (locale != null) {
      initializeDateFormatting(locale!.languageCode);
    }
    final displayDate = selectedDate ?? currentDate;
    final dateFormatter = isSingleLine
        ? DateFormat.MMMd(locale?.languageCode)
        : (dateFormat != null
              ? DateFormat(dateFormat, locale?.languageCode)
              : DateFormat.yMMMM(locale?.languageCode));

    final dateText = dateFormatter.format(displayDate);
    final todayText = isSingleLine && _isToday(displayDate)
        ? _getTodayText() != null
              ? ' ${_getTodayText()}'
              : ''
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showNavigation)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousMonth,
            ),
          Text(
            dateText + todayText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (showNavigation)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
            ),
        ],
      ),
    );
  }
}
