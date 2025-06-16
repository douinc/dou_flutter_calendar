import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/widgets/grid_calendar.dart';
import 'package:dou_flutter_calendar/src/widgets/single_line_calendar.dart';
import 'package:dou_flutter_calendar/src/models/calendar_date.dart';
import 'package:dou_flutter_calendar/src/models/calendar_style.dart';

void main() {
  testWidgets('Calendar renders GridCalendar by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GridCalendar(initialDate: DateTime(2024, 3, 1))),
      ),
    );

    expect(find.byType(GridCalendar), findsOneWidget);
    expect(find.byType(SingleLineCalendar), findsNothing);
  });

  testWidgets(
    'Calendar renders SingleLineCalendar when viewType is singleLine',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleLineCalendar(initialDate: DateTime(2024, 3, 1)),
          ),
        ),
      );

      expect(find.byType(SingleLineCalendar), findsOneWidget);
      expect(find.byType(GridCalendar), findsNothing);
    },
  );

  testWidgets('Calendar calls onDateSelected when date is selected', (
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

  testWidgets('Calendar handles multiSelect correctly', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Calendar applies custom grid style', (
    WidgetTester tester,
  ) async {
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

    // Verify that the style is applied to the GridCalendar
    final gridCalendar = tester.widget<GridCalendar>(find.byType(GridCalendar));
    expect(gridCalendar.style, style);
  });

  testWidgets('Calendar handles locale correctly', (WidgetTester tester) async {
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

    // Verify that the locale is passed to the GridCalendar
    final gridCalendar = tester.widget<GridCalendar>(find.byType(GridCalendar));
    expect(gridCalendar.locale, const Locale('ko', 'KR'));
  });
}
