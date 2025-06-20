/// Enum to define the type of calendar change
enum CalendarChangeType {
  selection, // Date was selected (should trigger callbacks)
  navigation, // View was navigated (should not trigger callbacks)
}
