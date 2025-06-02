import 'package:flutter/material.dart';
import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Example',
      theme: ThemeData(),
      home: const CalendarExampleScreen(),
    );
  }
}

class CalendarExampleScreen extends StatefulWidget {
  const CalendarExampleScreen({Key? key}) : super(key: key);

  @override
  State<CalendarExampleScreen> createState() => _CalendarExampleScreenState();
}

class _CalendarExampleScreenState extends State<CalendarExampleScreen> {
  CalendarViewType _selectedViewType = CalendarViewType.grid;
  DateTime _selectedDate = DateTime.now();
  List<CalendarDate> _selectedDates = [];
  bool _multiSelect = false;
  Locale _selectedLocale = const Locale('ko');

  final List<Map<String, dynamic>> _locales = [
    {'name': 'English', 'locale': const Locale('en')},
    {'name': '한국어', 'locale': const Locale('ko')},
    {'name': '日本語', 'locale': const Locale('ja')},
    {'name': '中文', 'locale': const Locale('zh')},
  ];

  List<CalendarDate> _generateDays(DateTime date) {
    final now = DateTime.now();
    return CalendarUtils.getDaysInMonth(date).map((day) {
      if (day.date.day == 2) {
        return day.copyWith(
          dateLabel: Text(
            '1 item',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.2,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
      if (day.date.weekday == DateTime.monday) {
        return day.copyWith(
          dateLabel: Text(
            'Meeting',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.2,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
      if (day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day) {
        return day.copyWith(
          dateLabel: Text(
            'Today',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.2,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
      return day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Example'),
      ),
      body: Column(
        children: [
          DropdownButton<Locale>(
            value: _selectedLocale,
            items: _locales
                .map((locale) => DropdownMenuItem<Locale>(
                      value: locale['locale'] as Locale,
                      child: Text(locale['name'] as String),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLocale = value;
                });
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedViewType = CalendarViewType.singleLine;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedViewType == CalendarViewType.singleLine
                          ? Colors.blue
                          : Colors.grey,
                ),
                child: const Text(
                  'Single Line Calendar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedViewType = CalendarViewType.grid;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedViewType == CalendarViewType.grid
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text(
                  'Grid Calendar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (_selectedViewType == CalendarViewType.grid)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Switch(
                  value: _multiSelect,
                  onChanged: (value) {
                    setState(() {
                      _multiSelect = value;
                    });
                  },
                ),
                Text(_multiSelect ? 'Multi Select' : 'Single Select'),
              ],
            ),
          Calendar(
            locale: _selectedLocale,
            viewType: _selectedViewType,
            initialDate: _selectedDate,
            initialSelectedDates: _selectedDates,
            multiSelect: _multiSelect,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onDatesSelected: (dates) {
              setState(() {
                _selectedDates = dates;
              });
            },
            // headerDateFormat: 'yyyy MM',
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Selected Date: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                style: const TextStyle(fontSize: 16),
              ),
              if (_multiSelect && _selectedDates.isNotEmpty)
                Text(
                  'Selected Dates: ${_selectedDates.map((d) => '${d.date.month}/${d.date.day}').join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
