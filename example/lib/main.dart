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

enum CalendarViewType { singleLine, grid }

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
  Locale _selectedLocale = const Locale('en');
  StartingDayOfWeek? _firstDayOfWeek; // null = follow the locale convention

  final List<Map<String, dynamic>> _locales = [
    {'name': 'English', 'locale': const Locale('en')},
    {'name': '한국어', 'locale': const Locale('ko')},
    {'name': '日本語', 'locale': const Locale('ja')},
    {'name': '中文', 'locale': const Locale('zh')},
  ];

  final List<Map<String, dynamic>> _firstDayOptions = [
    {'name': 'Locale default', 'value': null},
    {'name': 'Monday', 'value': StartingDayOfWeek.monday},
    {'name': 'Sunday', 'value': StartingDayOfWeek.sunday},
    {'name': 'Saturday', 'value': StartingDayOfWeek.saturday},
  ];

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
                    _selectedDate = DateTime.now();
                    _selectedDates = [];
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
                    _selectedDate = DateTime.now();
                    _selectedDates = [];
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
          if (_selectedViewType == CalendarViewType.grid) ...[
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                const Text('First day:'),
                DropdownButton<StartingDayOfWeek?>(
                  value: _firstDayOfWeek,
                  items: _firstDayOptions
                      .map((option) => DropdownMenuItem<StartingDayOfWeek?>(
                            value: option['value'] as StartingDayOfWeek?,
                            child: Text(option['name'] as String),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _firstDayOfWeek = value;
                    });
                  },
                ),
              ],
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _selectedViewType == CalendarViewType.grid ? 16 : 0,
              vertical: _selectedViewType == CalendarViewType.grid ? 0 : 15,
            ),
            child: _selectedViewType == CalendarViewType.singleLine
                ? SingleLineCalendar(
                    locale: _selectedLocale,
                    initialDate: _selectedDate,
                    initialSelectedDates: _selectedDates,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  )
                : GridCalendar(
                    locale: _selectedLocale,
                    initialDate: _selectedDate,
                    initialSelectedDates: _selectedDates,
                    multiSelect: _multiSelect,
                    firstDayOfWeek: _firstDayOfWeek,
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
                  ),
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
