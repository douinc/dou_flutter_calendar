import 'package:dou_flutter_calendar/src/models/calendar_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/controllers/single_line_calendar_controller.dart';

void main() {
  group('SingleLineCalendarController', () {
    late SingleLineCalendarController controller;

    setUp(() {
      controller = SingleLineCalendarController(
        initialDate: DateTime(2024, 3, 15),
      );
    });

    test('initialDate sets correctly', () {
      expect(controller.currentDate, DateTime(2024, 3, 15));
    });

    test('selectDate updates currentDate and notifies listeners', () {
      final newDate = DateTime(2024, 3, 20);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.selectDate(newDate);

      expect(controller.currentDate, newDate);
      expect(controller.lastChangeType, CalendarChangeType.selection);
      expect(notified, isTrue);
    });

    test('navigateToDate updates currentDate and notifies listeners', () {
      final newDate = DateTime(2024, 3, 20);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.navigateToDate(newDate);

      expect(controller.currentDate, newDate);
      expect(controller.lastChangeType, CalendarChangeType.navigation);
      expect(notified, isTrue);
    });

    test('nextDay selects the next day', () {
      controller.nextDay();
      expect(controller.currentDate, DateTime(2024, 3, 16));
    });

    test('previousDay selects the previous day', () {
      controller.previousDay();
      expect(controller.currentDate, DateTime(2024, 3, 14));
    });

    test('goToToday selects today', () {
      controller.goToToday();
      final now = DateTime.now();
      expect(controller.currentDate.year, now.year);
      expect(controller.currentDate.month, now.month);
      expect(controller.currentDate.day, now.day);
    });

    test('goToDate selects the specified date', () {
      controller.goToDate(2025, 1, 1);
      expect(controller.currentDate, DateTime(2025, 1, 1));
    });
  });
}
