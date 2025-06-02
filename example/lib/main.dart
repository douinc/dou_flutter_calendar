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
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final now = DateTime.now();
      // selectedDate = now;
      _isInitialized = true;
    }
  }

  List<CalendarDate> _generateDays(DateTime date) {
    final now = DateTime.now();
    return CalendarUtils.getDaysInMonth(date).map((day) {
      if (day.date.day == 15) {
        return day.copyWith(
          dateLabel: Text(
            '1일',
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
                });
              },
              onGenerateDays: _generateDays,
              headerDateFormat: 'MM월',
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
