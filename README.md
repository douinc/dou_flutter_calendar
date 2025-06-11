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

[![pub package](https://img.shields.io/pub/v/dou_flutter_calendar.svg)](https://pub.dev/packages/dou_flutter_calendar)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.32.1-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.8.0-blue)](https://dart.dev)
[![Test Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)](https://github.com/douinc/dou_flutter_calendar/actions)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/douinc/dou_flutter_calendar/pulls)
[![GitHub issues](https://img.shields.io/github/issues/douinc/dou_flutter_calendar?cache=1)](https://github.com/douinc/dou_flutter_calendar/issues)
[![GitHub stars](https://img.shields.io/github/stars/douinc/dou_flutter_calendar?cache=1)](https://github.com/douinc/dou_flutter_calendar/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/douinc/dou_flutter_calendar?cache=1)](https://github.com/douinc/dou_flutter_calendar/network/members)

A highly customizable and feature-rich calendar widget for Flutter applications. This package provides flexible calendar implementations with various views and customization options.

## Demo

![Calendar Demo](https://github.com/douinc/dou_flutter_calendar/blob/main/docs/calendar_demo.gif?raw=true)

## Features

- **Multiple Calendar View Types**:
  - Grid view (traditional month view)
  - Single line view (horizontal scrolling)
- **Multi-date Selection Support**: Choose multiple dates or single date
- **Customizable Styles and Themes**: Full control over appearance with separate styles for Grid and Single Line views
- **Internationalization Support**: 
  - English (en)
  - Korean (한국어, ko)
  - Japanese (日本語, ja)
  - Chinese (中文, zh)
- **Flexible Date Formatting**: Custom date formats for headers
- **Custom Day and Header Rendering**: Full control over individual day cells and calendar headers
- **Calendar Controller**: Programmatic control over calendar state with navigation and selection modes
- **Advanced Single Line Calendar**: Smooth scrolling with infinite date loading and intelligent date selection
- **Responsive Design**: Adapts to different screen sizes and orientations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dou_flutter_calendar: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Grid Calendar

```dart
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';

Calendar(
  viewType: CalendarViewType.grid,
  initialDate: DateTime.now(),
  onDateSelected: (DateTime date) {
    print('Selected date: $date');
  },
)
```

### Single Line Calendar

```dart
Calendar(
  viewType: CalendarViewType.singleLine,
  initialDate: DateTime.now(),
  dayWidth: 50.0, // Custom day width
  onDateSelected: (DateTime date) {
    print('Selected date: $date');
  },
)
```

### Multi-Select Calendar

```dart
Calendar(
  viewType: CalendarViewType.grid,
  multiSelect: true,
  initialSelectedDates: [
    CalendarDate(date: DateTime.now()),
  ],
  onDatesSelected: (List<CalendarDate> dates) {
    print('Selected dates: ${dates.map((d) => d.date).toList()}');
  },
)
```

### Calendar with Custom Styling

```dart
Calendar(
  viewType: CalendarViewType.grid,
  gridStyle: GridCalendarStyle(
    selectionColor: Colors.blue,
    dateTextStyle: TextStyle(fontSize: 16),
    weekdayTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    cellHeight: 60,
    cellBorderRadius: 12,
    showNavigationButtons: true,
  ),
  onDateSelected: (date) {
    // Handle selection
  },
)
```

### Single Line Calendar with Custom Style

```dart
Calendar(
  viewType: CalendarViewType.singleLine,
  dayWidth: 60.0,
  singleLineStyle: SingleLineCalendarStyle(
    weekdayTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    dateSpacing: 8.0,
    showNavigationButtons: false,
  ),
  onDateSelected: (date) {
    // Handle selection
  },
)
```

### Calendar with Localization

```dart
Calendar(
  locale: const Locale('ko'), // Korean
  viewType: CalendarViewType.grid,
  initialDate: DateTime.now(),
  onDateSelected: (DateTime date) {
    // Handle date selection
  },
)
```

### Advanced Usage with Calendar Controller

```dart
class MyCalendarWidget extends StatefulWidget {
  @override
  _MyCalendarWidgetState createState() => _MyCalendarWidgetState();
}

class _MyCalendarWidgetState extends State<MyCalendarWidget> {
  late CalendarController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = CalendarController(initialDate: DateTime.now());
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar widget
        Calendar(
          controller: _controller,
          viewType: CalendarViewType.grid,
          initialDate: DateTime.now(),
          onDateSelected: (date) {
            print('Date selected via UI: $date');
          },
        ),
        
        // Control buttons
        Wrap(
          spacing: 8.0,
          children: [
            ElevatedButton(
              onPressed: () => _controller.previousMonth(),
              child: Text('Previous Month'),
            ),
            ElevatedButton(
              onPressed: () => _controller.nextMonth(),
              child: Text('Next Month'),
            ),
            ElevatedButton(
              onPressed: () => _controller.goToToday(),
              child: Text('Today'),
            ),
            ElevatedButton(
              onPressed: () => _controller.nextDay(),
              child: Text('Next Day'),
            ),
            ElevatedButton(
              onPressed: () => _controller.previousDay(),
              child: Text('Previous Day'),
            ),
            ElevatedButton(
              onPressed: () => _controller.goToDate(2024, 12, 25),
              child: Text('Christmas'),
            ),
          ],
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Custom Day Builder

```dart
Calendar(
  viewType: CalendarViewType.grid,
  dayBuilder: (CalendarDate calendarDate) {
    return Container(
      decoration: BoxDecoration(
        color: calendarDate.isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: calendarDate.isToday 
          ? Border.all(color: Colors.red, width: 2)
          : null,
      ),
      child: Center(
        child: Text(
          calendarDate.date.day.toString(),
          style: TextStyle(
            color: calendarDate.isSelected ? Colors.white : Colors.black,
            fontWeight: calendarDate.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  },
  onDateSelected: (date) {
    // Handle selection
  },
)
```

### Custom Header Builder

```dart
Calendar(
  viewType: CalendarViewType.grid,
  headerBuilder: (DateTime currentDate) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        DateFormat.yMMMM().format(currentDate),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  },
  onDateSelected: (date) {
    // Handle selection
  },
)
```

## API Reference

### Calendar Widget Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `viewType` | `CalendarViewType` | Calendar view type (grid or singleLine) | `CalendarViewType.grid` |
| `initialDate` | `DateTime?` | Initial date to display | `DateTime.now()` |
| `initialSelectedDates` | `List<CalendarDate>?` | Initially selected dates for multi-select | `null` |
| `multiSelect` | `bool` | Enable multi-date selection | `false` |
| `locale` | `Locale?` | Locale for internationalization | System locale |
| `gridStyle` | `GridCalendarStyle?` | Custom styling options for grid view | Default style |
| `singleLineStyle` | `SingleLineCalendarStyle?` | Custom styling options for single line view | Default style |
| `headerDateFormat` | `String?` | Custom header date format | `null` |
| `onDateSelected` | `Function(DateTime)?` | Single date selection callback | `null` |
| `onDatesSelected` | `Function(List<CalendarDate>)?` | Multi-date selection callback | `null` |
| `controller` | `CalendarController?` | Calendar controller for programmatic control | `null` |
| `dayBuilder` | `Widget Function(CalendarDate)?` | Custom day cell builder | `null` |
| `headerBuilder` | `Widget Function(DateTime)?` | Custom header builder | `null` |
| `dayWidth` | `double` | Width of each day in single line view | `50.0` |
| `days` | `List<CalendarDate>?` | Custom list of days to display | Auto-generated |

### GridCalendarStyle Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `selectionColor` | `Color?` | Color for selected dates | `Colors.blue` |
| `dateTextStyle` | `TextStyle?` | Text style for date numbers | Default text style |
| `weekdayTextStyle` | `TextStyle?` | Text style for weekday headers | Default text style |
| `todayBackgroundColor` | `Color?` | Background color for today's date | `null` |
| `cellHeight` | `double?` | Height of each calendar cell | `60.0` |
| `cellPadding` | `double?` | Padding inside each cell | `4.0` |
| `cellBorderRadius` | `double?` | Border radius for cells | `8.0` |
| `cellBorderWidth` | `double?` | Border width for selected cells | `2.0` |
| `rowSpacing` | `double?` | Spacing between calendar rows | `8.0` |
| `otherMonthOpacity` | `double?` | Opacity for dates from other months | `0.2` |
| `showNavigationButtons` | `bool?` | Show navigation arrows in header | `true` |

### SingleLineCalendarStyle Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `weekdayTextStyle` | `TextStyle?` | Text style for weekday headers | Default text style |
| `dateSpacing` | `double?` | Spacing between date items | `4.0` |
| `showNavigationButtons` | `bool?` | Show navigation buttons | `true` |

### CalendarController Methods

| Method | Description | Triggers Callback |
|--------|-------------|-------------------|
| `selectDate(DateTime date)` | Select a specific date | ✅ Yes |
| `navigateToDate(DateTime date)` | Navigate to date without selection | ❌ No |
| `nextMonth()` | Move to next month | ❌ No |
| `previousMonth()` | Move to previous month | ❌ No |
| `nextDay()` | Move to next day | ✅ Yes |
| `previousDay()` | Move to previous day | ✅ Yes |
| `goToToday()` | Move to today | ✅ Yes |
| `goToDate(int year, int month, int day)` | Go to specific date | ✅ Yes |

### Supported Locales

- `en` - English
- `ko` - Korean (한국어)
- `ja` - Japanese (日本語)
- `zh` - Chinese (中文)

## Development

### Running Tests

```bash
flutter test
```

### Running the Example

```bash
cd example
flutter run
```

### Building Documentation

```bash
dart doc
```

## Requirements

- **Flutter SDK**: ^3.32.1
- **Dart SDK**: ^3.8.0
- **Minimum Flutter version**: 3.32.1

## Dependencies

- `flutter`: SDK
- `intl`: ^0.20.2

## Development Dependencies

- `flutter_test`: SDK
- `flutter_lints`: ^5.0.0

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details about changes in each version.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created and maintained by [Dou](https://dou.so).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- 📧 **Email**: [Contact Dou](https://dou.so)
- 🐛 **Issues**: [GitHub Issues](https://github.com/douinc/dou_flutter_calendar/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/douinc/dou_flutter_calendar/discussions)

## Related Projects

- [Flutter Calendar Widgets](https://flutter.dev/docs/catalog/calendar)
- [Table Calendar](https://pub.dev/packages/table_calendar)

---

⭐ **If you like this package, please give it a star on [GitHub](https://github.com/douinc/dou_flutter_calendar)!**
