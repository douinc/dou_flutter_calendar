import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeader({
    super.key,
    required this.currentDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Text(
            CalendarUtils.getMonthName(currentDate),
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
