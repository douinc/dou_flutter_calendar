class CalendarDate {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  const CalendarDate({
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isDisabled = false,
  });

  CalendarDate copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isToday,
    bool? isDisabled,
  }) {
    return CalendarDate(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}
