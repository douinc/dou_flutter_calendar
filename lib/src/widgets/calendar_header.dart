import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final DateTime? selectedDate;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final String? dateFormat;
  final bool showNavigation;
  final bool isSingleLine;
  final Locale? locale;

  const CalendarHeader({
    super.key,
    required this.currentDate,
    this.selectedDate,
    this.onPreviousMonth,
    this.onNextMonth,
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

  bool _isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
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

  String? _getYesterdayText() {
    const translations = {
      'en': '(Yesterday)',
      'ko': '(어제)',
      'ja': '(昨日)',
      'zh': '(昨天)',
    };
    return translations[locale?.languageCode];
  }

  @override
  Widget build(BuildContext context) {
    if (locale != null) {
      initializeDateFormatting(locale!.languageCode);
    }
    final displayDate = selectedDate ?? currentDate;
    final dateFormatter = dateFormat != null
        ? DateFormat(dateFormat, locale?.languageCode)
        : (isSingleLine
              ? DateFormat.MMMd(locale?.languageCode)
              : DateFormat.yMMMM(locale?.languageCode));

    final dateText = dateFormatter.format(displayDate);
    String additionalText = '';
    if (isSingleLine && dateFormat == null) {
      if (_isToday(displayDate) && _getTodayText() != null) {
        additionalText = '${_getTodayText()}';
      } else if (_isYesterday(displayDate) && _getYesterdayText() != null) {
        additionalText = '${_getYesterdayText()}';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showNavigation)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousMonth,
            ),
          Text(
            dateText + additionalText,
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
