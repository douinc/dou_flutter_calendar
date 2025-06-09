import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final String dateText;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showNavigationButtons;

  const CalendarHeader({
    super.key,
    required this.dateText,
    this.onPrevious,
    this.onNext,
    this.showNavigationButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showNavigationButtons)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            )
          else
            const SizedBox(width: 48), // IconButton과 같은 크기의 공간 유지
          Text(dateText, style: Theme.of(context).textTheme.titleLarge),
          if (showNavigationButtons)
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext)
          else
            const SizedBox(width: 48), // IconButton과 같은 크기의 공간 유지
        ],
      ),
    );
  }
}
