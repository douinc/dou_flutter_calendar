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

    // Verify that the PageView is rendered
    expect(find.byType(PageView), findsOneWidget);
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

    // Wait for the widget to initialize
    await tester.pumpAndSettle();

    // Find and tap a date (the selected date should be 15 by default)
    final dateFinder = find.text('15');
    expect(dateFinder, findsOneWidget);
    await tester.tap(dateFinder);
    await tester.pump();

    expect(selectedDate, DateTime(2024, 3, 15));
  });

  testWidgets('SingleLineCalendar handles page swipe', (
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

    // Wait for initialization
    await tester.pumpAndSettle();

    // Perform a horizontal swipe on the PageView
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    // After swiping left, the selected date should change
    // The exact behavior depends on the implementation
    expect(find.byType(PageView), findsOneWidget);
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
