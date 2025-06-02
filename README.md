<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Dou Flutter Calendar

A highly customizable and feature-rich calendar widget for Flutter applications. This package provides flexible calendar implementations with various views and customization options.

## Features

- Multiple calendar view types:
  - Grid view (traditional month view)
  - Single line view (horizontal scrolling)
- Multi-date selection support
- Customizable styles and themes
- Localization support
- Flexible date formatting
- Custom day rendering capabilities
- Header customization options

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dou_flutter_calendar: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Implementation

```dart
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';

Calendar(
  initialDate: DateTime.now(),
  onDateSelected: (DateTime date) {
    // Handle date selection
  },
)
```

### Grid Calendar View

```dart
Calendar(
  viewType: CalendarViewType.grid,
  initialDate: DateTime.now(),
  onDateSelected: (DateTime date) {
    // Handle date selection
  },
  style: CalendarStyle(
    // Customize your calendar appearance
  ),
)
```

### Single Line Calendar View

```dart
Calendar(
  viewType: CalendarViewType.singleLine,
  initialDate: DateTime.now(),
  onDateSelected: (DateTime date) {
    // Handle date selection
  },
)
```

### Multi-Select Calendar

```dart
Calendar(
  multiSelect: true,
  initialSelectedDates: [
    CalendarDate(date: DateTime.now()),
  ],
  onDatesSelected: (List<CalendarDate> dates) {
    // Handle multiple date selection
  },
)
```

## Customization

### Calendar Style

You can customize the appearance of your calendar using `CalendarStyle`:

```dart
Calendar(
  style: CalendarStyle(
    // Add your custom styles here
  ),
)
```

### Localization

The calendar supports different locales:

```dart
Calendar(
  locale: const Locale('ko', 'KR'), // Korean locale
  // ... other properties
)
```

### Custom Date Format

You can specify custom date formats for the header:

```dart
Calendar(
  headerDateFormat: 'MMMM yyyy',
  // ... other properties
)
```

## Requirements

- Flutter SDK: ^3.8.1
- Dart SDK: ^3.8.1
- Flutter: >= 1.17.0

## Dependencies

- intl: ^0.20.2

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created and maintained by [Dou](https://dou.so).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
