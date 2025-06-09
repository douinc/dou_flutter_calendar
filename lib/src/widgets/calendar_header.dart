import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final String dateText;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const CalendarHeader({
    super.key,
    required this.dateText,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(dateText, style: Theme.of(context).textTheme.titleLarge),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}
