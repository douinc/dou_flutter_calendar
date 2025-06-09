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
      title: 'Calendar Controller Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarControllerExample(),
    );
  }
}

class CalendarControllerExample extends StatefulWidget {
  const CalendarControllerExample({super.key});

  @override
  State<CalendarControllerExample> createState() =>
      _CalendarControllerExampleState();
}

class _CalendarControllerExampleState extends State<CalendarControllerExample> {
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController(initialDate: DateTime.now());
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Controller 예제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 함수 호출 버튼들
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: () => _calendarController.goToToday(),
                  child: const Text('오늘로 이동'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.nextDay(),
                  child: const Text('다음 날'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.previousDay(),
                  child: const Text('이전 날'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.nextMonth(),
                  child: const Text('다음 달'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.previousMonth(),
                  child: const Text('이전 달'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.goToDate(2024, 12, 25),
                  child: const Text('크리스마스로'),
                ),
                ElevatedButton(
                  onPressed: () => _calendarController.selectDate(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                  child: const Text('일주일 후'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 그리드 캘린더
            const Text('그리드 캘린더',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Calendar(
              controller: _calendarController,
              viewType: CalendarViewType.grid,
              onDateSelected: (date) {
                print('선택된 날짜: $date');
              },
            ),

            const SizedBox(height: 20),

            // 싱글 라인 캘린더
            const Text('싱글 라인 캘린더',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Calendar(
              controller: _calendarController,
              viewType: CalendarViewType.singleLine,
              onDateSelected: (date) {
                print('선택된 날짜: $date');
              },
            ),
          ],
        ),
      ),
    );
  }
}
