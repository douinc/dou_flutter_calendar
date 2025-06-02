import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/widgets/single_line_calendar.dart';
import 'package:dou_flutter_calendar/src/widgets/calendar_header.dart';
import 'package:dou_flutter_calendar/src/models/calendar_style.dart';

void main() {
  testWidgets('SingleLineCalendar renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleLineCalendar(
            viewType: CalendarViewType.singleLine,
            initialDate: DateTime(2024, 3, 1),
          ),
        ),
      ),
    );

    // Verify that the calendar header is rendered
    expect(find.byType(CalendarHeader), findsOneWidget);

    // Verify that the horizontal scroll view is rendered
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('SingleLineCalendar handles date selection', (
    WidgetTester tester,
  ) async {
    DateTime? selectedDate;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleLineCalendar(
            viewType: CalendarViewType.singleLine,
            initialDate: DateTime(2024, 3, 15),
            onDateSelected: (date) {
              selectedDate = date;
            },
          ),
        ),
      ),
    );

    // Find and tap a date
    final dateFinder = find.text('15').first;
    expect(dateFinder, findsOneWidget);
    await tester.tap(dateFinder);
    await tester.pump();

    expect(selectedDate, DateTime(2024, 3, 15));
  });

  testWidgets('SingleLineCalendar handles horizontal swipe', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleLineCalendar(
            viewType: CalendarViewType.singleLine,
            initialDate: DateTime(2024, 3, 15),
          ),
        ),
      ),
    );

    // Perform a horizontal swipe
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-300, 0),
    );
    await tester.pump();

    // Verify that the date has changed
    expect(find.text('16').first, findsOneWidget);
  });

  testWidgets('SingleLineCalendar handles locale correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleLineCalendar(
            viewType: CalendarViewType.singleLine,
            initialDate: DateTime(2024, 3, 1),
            locale: const Locale('ko', 'KR'),
          ),
        ),
      ),
    );

    // Verify that the locale is applied to the header
    final header = tester.widget<CalendarHeader>(find.byType(CalendarHeader));
    expect(header.locale, const Locale('ko', 'KR'));
  });

  testWidgets('SingleLineCalendar handles custom date format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleLineCalendar(
            viewType: CalendarViewType.singleLine,
            initialDate: DateTime(2024, 3, 1),
            headerDateFormat: 'MMM d',
          ),
        ),
      ),
    );

    // Verify that the custom date format is applied
    expect(find.text('Mar 1'), findsOneWidget);
  });
}
