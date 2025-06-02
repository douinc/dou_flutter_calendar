import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final String? dateFormat;

  const CalendarHeader({
    super.key,
    required this.currentDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Text(
            dateFormat != null
                ? DateFormat(dateFormat).format(currentDate)
                : CalendarUtils.getMonthName(currentDate),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
