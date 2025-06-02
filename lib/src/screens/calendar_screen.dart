import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../models/calendar_date.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<CalendarDate> _selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          Calendar(
            initialSelectedDates: _selectedDates,
            onDatesSelected: (dates) {
              setState(() {
                _selectedDates = dates;
              });
            },
            multiSelect: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Selected dates: ${_selectedDates.map((d) => d.date.toString()).join(", ")}',
          ),
        ],
      ),
    );
  }
}
