import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_of_mine/models/event.dart';

class CustomCalendar extends StatefulWidget {
  final Map<DateTime, List<Event>> eventMap;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CustomCalendar({
    super.key,
    required this.eventMap,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCalendar<Event>(
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: theme.textTheme.titleLarge!.color),
      ),
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      eventLoader: (day) {
        final normalized = DateTime.utc(day.year, day.month, day.day);
        return widget.eventMap[normalized] ?? [];
      },
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay, focusedDay);
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: theme.textTheme.titleLarge!.color),
        weekendTextStyle: TextStyle(color: theme.textTheme.titleLarge!.color),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            // Проверяем, есть ли праздник
            final hasHoliday = events.any((e) => e.type == 'Holiday');

            return Positioned(
              right: 1,
              bottom: 1,
              child: Icon(
                Icons.event,
                color: hasHoliday ? Colors.red : Colors.deepPurple,
                size: 16,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
