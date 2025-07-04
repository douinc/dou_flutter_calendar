## 0.0.5

* **BREAKING CHANGES**:
  - Replaced the generic `CalendarController` with `GridCalendarController` and `SingleLineCalendarController` to provide specific APIs for each calendar type. `GridCalendar` now requires a `GridCalendarController` and `SingleLineCalendar` requires a `SingleLineCalendarController`.
* **Improvements**:
  - Updated `README.md` with detailed usage instructions for the new `GridCalendarController` and `SingleLineCalendarController`.
  - Refactored controller logic to better separate concerns between grid and single-line calendars.
  - `GridCalendarController` now includes month navigation methods like `nextMonth()`, `previousMonth()`, and `goToMonth()`.

## 0.0.4

* **BREAKING CHANGES**:
  - Removed `Calendar` widget, which has been replaced by `GridCalendar` and `SingleLineCalendar`.
* **New Features**:
  - Added `onMonthChanged` callback to `GridCalendar` to handle month change events.
  - Implemented `PageView` in `GridCalendar` for month-to-month navigation.
  - Added `calendarHeight` property to `GridCalendarStyle` for custom height adjustment.
* **Improvements**:
  - Replaced `Calendar` widget with `GridCalendar` and `SingleLineCalendar` throughout the library, examples, and tests for improved clarity and consistency.
  - Enhanced `GridCalendar`'s date selection logic for multi-select functionality.
  - Streamlined calendar-related exports.
  - Updated README to reflect the new widget structure and properties.
  - Removed unused `dispose` method in `CalendarController`.

## 0.0.3

* **BREAKING CHANGES**: 
  - Deprecated `CalendarStyle` in favor of separate `GridCalendarStyle` and `SingleLineCalendarStyle`
  - Replaced generic `style` parameter with `gridStyle` and `singleLineStyle` parameters
* **New Features**:
  - Added `dayBuilder` parameter for complete custom day cell rendering
  - Added `headerBuilder` parameter for custom calendar header rendering
  - Added `dayWidth` parameter for single line calendar customization
  - Added `days` parameter to provide custom day list
  - Enhanced CalendarController with navigation vs selection distinction
  - Added more CalendarController methods: `nextDay()`, `previousDay()`, `goToDate()`
  - Improved single line calendar with infinite scrolling and better performance
* **Improvements**:
  - Separated styling systems for grid and single line calendars
  - Enhanced CalendarController with `CalendarChangeType` to differentiate navigation from selection
  - Better performance optimization for single line calendar with date index mapping
  - Improved scroll behavior and date selection in single line view
  - Enhanced example with more comprehensive controller usage
* **Bug Fixes**:
  - Fixed controller listener management and disposal
  - Improved date synchronization between controller and UI
  - Better handling of programmatic vs user interactions

## 0.0.2

* Added comprehensive README documentation
* Enhanced API documentation with detailed property descriptions
* Added support for multiple locales (English, Korean, Japanese, Chinese)
* Improved example code with better usage demonstrations
* Added Calendar Controller for programmatic calendar control
* Enhanced customization options documentation
* Added development and contribution guidelines

## 0.0.1

* Initial release with basic calendar functionality
* Grid and single-line calendar view types
* Multi-date selection support
* Basic customization options
* Localization support foundation
