import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/models/calendar_style.dart';

void main() {
  group('GridCalendarStyle', () {
    test('copyWith creates new instance with updated values', () {
      const original = GridCalendarStyle(
        selectionColor: Colors.blue,
        dateTextStyle: TextStyle(color: Colors.black),
      );

      final updated = original.copyWith(
        selectionColor: Colors.red,
        dateTextStyle: const TextStyle(color: Colors.white),
      );

      expect(updated.selectionColor, Colors.red);
      expect(updated.dateTextStyle, const TextStyle(color: Colors.white));
    });

    test('copyWith keeps original values when not specified', () {
      const original = GridCalendarStyle(
        selectionColor: Colors.blue,
        dateTextStyle: TextStyle(color: Colors.black),
      );

      final updated = original.copyWith(selectionColor: Colors.red);

      expect(updated.selectionColor, Colors.red);
      expect(updated.dateTextStyle, original.dateTextStyle);
    });
  });

  group('SingleLineCalendarStyle', () {
    test('copyWith creates new instance with updated values', () {
      const original = SingleLineCalendarStyle(
        weekdayTextStyle: TextStyle(color: Colors.black),
        dateSpacing: 10.0,
      );

      final updated = original.copyWith(
        weekdayTextStyle: const TextStyle(color: Colors.white),
        dateSpacing: 20.0,
      );

      expect(updated.weekdayTextStyle, const TextStyle(color: Colors.white));
      expect(updated.dateSpacing, 20.0);
    });

    test('copyWith keeps original values when not specified', () {
      const original = SingleLineCalendarStyle(
        weekdayTextStyle: TextStyle(color: Colors.black),
        dateSpacing: 10.0,
      );

      final updated = original.copyWith(dateSpacing: 20.0);

      expect(updated.weekdayTextStyle, original.weekdayTextStyle);
      expect(updated.dateSpacing, 20.0);
    });
  });
}
