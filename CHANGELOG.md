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
