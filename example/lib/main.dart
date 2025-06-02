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
      title: 'Dou Flutter Calendar Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? selectedDate;
  final List<CalendarDate> _selectedDates = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final now = DateTime.now();
      selectedDate = now;
      final days = _generateDays(now);
      final selected = days.firstWhere(
        (d) =>
            d.date.year == now.year &&
            d.date.month == now.month &&
            d.date.day == now.day,
        orElse: () => CalendarDate(date: now, isSelected: true),
      );
      _selectedDates.add(selected.copyWith(isSelected: true));
      _isInitialized = true;
    }
  }

  List<CalendarDate> _generateDays(DateTime date) {
    final now = DateTime.now();
    return CalendarUtils.getDaysInMonth(date).map((day) {
      if (day.date.day == 15) {
        return day.copyWith(
          dateLabel: Text(
            '급여일',
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
        title: const Text('Dou Flutter Calendar Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Calendar(
              initialDate: DateTime.now(),
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                  _selectedDates.clear();
                  // 현재 월의 days를 생성
                  final days = _generateDays(date);
                  // 선택한 날짜의 CalendarDate를 찾음
                  final selected = days.firstWhere(
                    (d) =>
                        d.date.year == date.year &&
                        d.date.month == date.month &&
                        d.date.day == date.day,
                    orElse: () => CalendarDate(date: date, isSelected: true),
                  );
                  _selectedDates.add(selected.copyWith(isSelected: true));
                });
              },
              selectedDates: _selectedDates,
              onGenerateDays: _generateDays,
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              Text(
                'Selected date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
      ),
    );
  }
}
