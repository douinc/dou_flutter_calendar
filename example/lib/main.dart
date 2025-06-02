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
  CalendarViewType _selectedViewType = CalendarViewType.singleLine;
  DateTime _selectedDate = DateTime.now();
  List<CalendarDate> _selectedDates = [];
  bool _multiSelect = false;

  List<CalendarDate> _generateDays(DateTime date) {
    final now = DateTime.now();
    return CalendarUtils.getDaysInMonth(date).map((day) {
      if (day.date.day == 2) {
        return day.copyWith(
          dateLabel: Text(
            '1건',
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
            '회의',
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
            '오늘',
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
                  '한 줄 캘린더',
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
                  '그리드 캘린더',
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
                Text(_multiSelect ? '다중 선택' : '단일 선택'),
              ],
            ),
          if (_selectedViewType == CalendarViewType.singleLine)
            SingleLineCalendar(
              viewType: _selectedViewType,
              initialDate: _selectedDate,
              initialSelectedDates: _selectedDates,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onGenerateDays: _generateDays,
              style: const CalendarStyle(
                selectionColor: Colors.blue,
                dateTextStyle: TextStyle(fontSize: 16),
                weekdayTextStyle: TextStyle(fontSize: 12),
              ),
              headerDateFormat: 'MM월',
            )
          else
            Calendar(
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
              onGenerateDays: _generateDays,
              headerDateFormat: 'MM월',
            ),
          Column(
            children: [
              const SizedBox(height: 20),
              Text(
                '선택된 날짜: ${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                style: const TextStyle(fontSize: 16),
              ),
              if (_multiSelect && _selectedDates.isNotEmpty)
                Text(
                  '선택된 날짜들: ${_selectedDates.map((d) => '${d.date.month}/${d.date.day}').join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
