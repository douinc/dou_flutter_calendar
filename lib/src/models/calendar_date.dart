class CalendarDate {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;

  const CalendarDate({
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isCurrentMonth = false,
  });

  CalendarDate copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isToday,
    bool? isCurrentMonth,
  }) {
    return CalendarDate(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
    );
  }
}
