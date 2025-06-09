class CalendarDate {
  final DateTime date;
  final bool isSelected;
  final bool isToday;

  const CalendarDate({
    required this.date,
    this.isSelected = false,
    this.isToday = false,
  });

  CalendarDate copyWith({DateTime? date, bool? isSelected, bool? isToday}) {
    return CalendarDate(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
    );
  }
}
