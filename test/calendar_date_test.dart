import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/models/calendar_date.dart';

void main() {
  group('CalendarDate', () {
    test('creates with default values', () {
      final date = DateTime(2024, 3, 1);
      final calendarDate = CalendarDate(date: date);

      expect(calendarDate.date, date);
      expect(calendarDate.isSelected, false);
      expect(calendarDate.isToday, false);
    });

    test('creates with custom values', () {
      final date = DateTime(2024, 3, 1);
      final calendarDate = CalendarDate(
        date: date,
        isSelected: true,
        isToday: true,
      );

      expect(calendarDate.date, date);
      expect(calendarDate.isSelected, true);
      expect(calendarDate.isToday, true);
    });

    test('copyWith creates new instance with updated values', () {
      final original = CalendarDate(
        date: DateTime(2024, 3, 1),
        isSelected: false,
        isToday: false,
      );

      final updated = original.copyWith(isSelected: true, isToday: true);

      expect(updated.date, original.date);
      expect(updated.isSelected, true);
      expect(updated.isToday, true);
    });

    test('copyWith keeps original values when not specified', () {
      final original = CalendarDate(
        date: DateTime(2024, 3, 1),
        isSelected: true,
        isToday: true,
      );

      final updated = original.copyWith(date: DateTime(2024, 3, 2));

      expect(updated.date, DateTime(2024, 3, 2));
      expect(updated.isSelected, original.isSelected);
      expect(updated.isToday, original.isToday);
    });
  });
}
