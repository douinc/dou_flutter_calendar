import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final String? description;
  final bool isAllDay;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.color,
    this.description,
    this.isAllDay = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    Color? color,
    String? description,
    bool? isAllDay,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      description: description ?? this.description,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}
