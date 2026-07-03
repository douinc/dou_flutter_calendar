/// Enum to define the type of calendar change
enum CalendarChangeType {
  selection, // Date was selected (should trigger callbacks)
  navigation, // View was navigated (should not trigger callbacks)
}

/// The day a calendar week starts on.
///
/// Passed to [GridCalendar.firstDayOfWeek] to control which weekday appears in
/// the first column. When left `null`, the calendar follows the convention of
/// the provided `locale` (e.g. Sunday for `ko`/`en_US`/`ja`, Monday for
/// `en_GB`/`fr`), matching how Flutter's own `CalendarDatePicker` behaves.
///
/// The enum order mirrors `DateTime.weekday` so that `index + 1` yields the
/// matching Dart weekday value (`DateTime.monday` == 1 ... `DateTime.sunday`
/// == 7).
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}
