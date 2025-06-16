import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/models/calendar_date.dart';
import 'package:dou_flutter_calendar/src/widgets/calendar_day.dart';

void main() {
  group('CalendarDay', () {
    testWidgets('renders correctly and handles tap', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;
      final calendarDate = CalendarDate(date: DateTime(2024, 3, 15));
      final currentMonth = DateTime(2024, 3, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDay(
              date: calendarDate,
              currentMonth: currentMonth,
              onDateSelected: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);

      await tester.tap(find.byType(CalendarDay));
      await tester.pump();

      expect(selectedDate, DateTime(2024, 3, 15));
    });

    testWidgets('shows selection style when selected', (
      WidgetTester tester,
    ) async {
      final calendarDate = CalendarDate(date: DateTime(2024, 3, 15));
      final currentMonth = DateTime(2024, 3, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDay(
              date: calendarDate,
              currentMonth: currentMonth,
              isSelected: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.border, isNotNull);
    });

    testWidgets('shows different style for other month', (
      WidgetTester tester,
    ) async {
      final calendarDate = CalendarDate(date: DateTime(2024, 4, 1));
      final currentMonth = DateTime(2024, 3, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDay(date: calendarDate, currentMonth: currentMonth),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('1'));
      expect(text.style?.color?.opacity, lessThan(1.0));
    });
  });
}
