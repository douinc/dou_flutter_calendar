import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/widgets/grid_calendar.dart';
import 'package:dou_flutter_calendar/src/widgets/calendar_header.dart';
import 'package:dou_flutter_calendar/src/widgets/calendar_month.dart';
import 'package:dou_flutter_calendar/src/models/calendar_date.dart';
import 'package:dou_flutter_calendar/src/models/calendar_style.dart';

void main() {
  testWidgets('GridCalendar renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GridCalendar(initialDate: DateTime(2024, 3, 1))),
      ),
    );

    // Verify that the calendar header is rendered
    expect(find.byType(CalendarHeader), findsOneWidget);

    // Verify that the calendar grid is rendered
    expect(find.byType(CalendarMonth), findsOneWidget);
  });

  testWidgets('GridCalendar handles date selection', (
    WidgetTester tester,
  ) async {
    DateTime? selectedDate;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridCalendar(
            initialDate: DateTime(2024, 3, 1),
            onDateSelected: (date) {
              selectedDate = date;
            },
          ),
        ),
      ),
    );

    // Find and tap a date
    final dateFinder = find.text('15');
    expect(dateFinder, findsOneWidget);
    await tester.tap(dateFinder);
    await tester.pump();

    expect(selectedDate, DateTime(2024, 3, 15));
  });

  testWidgets('GridCalendar handles multiSelect', (WidgetTester tester) async {
    List<CalendarDate> selectedDates = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridCalendar(
            initialDate: DateTime(2024, 3, 1),
            multiSelect: true,
            initialSelectedDates: [], // Start with no selected dates
            onDatesSelected: (dates) {
              selectedDates = dates;
            },
          ),
        ),
      ),
    );

    // Select first date
    await tester.tap(find.text('15'));
    await tester.pump();

    // Select second date
    await tester.tap(find.text('16'));
    await tester.pump();

    expect(selectedDates.length, 2);
    expect(selectedDates[0].date, DateTime(2024, 3, 15));
    expect(selectedDates[1].date, DateTime(2024, 3, 16));
  });

  testWidgets('GridCalendar handles month navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GridCalendar(initialDate: DateTime(2024, 3, 1))),
      ),
    );

    // Find and tap the next month button
    final nextButton = find.byIcon(Icons.chevron_right);
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Verify that the month has changed
    expect(find.text('April 2024'), findsOneWidget);
  });

  testWidgets('GridCalendar applies custom style', (WidgetTester tester) async {
    final style = GridCalendarStyle(
      selectionColor: Colors.red,
      dateTextStyle: const TextStyle(color: Colors.blue),
      weekdayTextStyle: const TextStyle(color: Colors.green),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridCalendar(initialDate: DateTime(2024, 3, 1), style: style),
        ),
      ),
    );

    // Verify that the style is applied to the CalendarMonth
    final calendarMonth = tester.widget<CalendarMonth>(
      find.byType(CalendarMonth),
    );
    expect(calendarMonth.style, style);
  });

  testWidgets('GridCalendar handles locale correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridCalendar(
            initialDate: DateTime(2024, 3, 1),
            locale: const Locale('ko', 'KR'),
          ),
        ),
      ),
    );

    // Verify that the locale is passed to the CalendarMonth
    final calendarMonth = tester.widget<CalendarMonth>(
      find.byType(CalendarMonth),
    );
    expect(calendarMonth.locale, const Locale('ko', 'KR'));
  });
}
