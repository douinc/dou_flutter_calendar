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

A customizable and feature-rich calendar widget for Flutter applications. This package provides a flexible calendar implementation that can be used for various calendar-related features in your Flutter projects.

## Features

- Single line calendar view
- Full calendar view with month navigation
- Customizable calendar styles
- Event support
- Date selection functionality
- Week and month views
- Header customization
- Day cell customization

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dou_flutter_calendar: ^0.0.1
```

## Usage

Import the package in your Dart code:

```dart
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
```

### Basic Calendar Implementation

```dart
Calendar(
  onDateSelected: (date) {
    // Handle date selection
  },
  events: [
    CalendarEvent(
      date: DateTime.now(),
      title: 'Sample Event',
    ),
  ],
)
```

### Single Line Calendar

```dart
SingleLineCalendar(
  onDateSelected: (date) {
    // Handle date selection
  },
)
```

## Components

The package includes several customizable components:

- `Calendar`: Main calendar widget
- `SingleLineCalendar`: Compact single-line calendar view
- `CalendarHeader`: Customizable calendar header
- `CalendarDay`: Individual day cell widget
- `CalendarWeek`: Week view widget
- `CalendarMonth`: Month view widget

## Customization

You can customize the calendar's appearance using the `CalendarStyle` class:

```dart
Calendar(
  style: CalendarStyle(
    // Customize your calendar style
  ),
)
```

## Dependencies

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.8.1
- intl: ^0.19.0

## License

This project is licensed under the terms specified in the LICENSE file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
