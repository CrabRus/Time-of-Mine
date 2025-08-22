import 'package:flutter/material.dart';

class TypesConfig {
  // Типы заданий
  static final List<Map<String, dynamic>> taskTypes = [
    {"name": "Homework", "icon": Icons.book},
    {"name": "Project", "icon": Icons.work},
    {"name": "Exam", "icon": Icons.school},
    {"name": "Lecture", "icon": Icons.menu_book},
    {"name": "Workshop", "icon": Icons.build},
    {"name": "Appointment", "icon": Icons.event},
    {"name": "Chores", "icon": Icons.cleaning_services},
    {"name": "Bill", "icon": Icons.payment},
    {"name": "Study", "icon": Icons.lightbulb},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Other", "icon": Icons.event_note},
  ];

  // Типы событий
  static final List<Map<String, dynamic>> eventTypes = [
    {"name": "Birthday", "icon": Icons.cake},
    {"name": "Anniversary", "icon": Icons.favorite},
    {"name": "Meeting", "icon": Icons.people},
    {"name": "Deadline", "icon": Icons.timer},
    {"name": "Reminder", "icon": Icons.notifications},
    {"name": "Travel", "icon": Icons.flight_takeoff},
    {"name": "Workout", "icon": Icons.fitness_center},
    {"name": "Health", "icon": Icons.local_hospital},
    {"name": "Shopping", "icon": Icons.shopping_cart},
    {"name": "Other", "icon": Icons.event_note},
  ];

  // Получить иконку по названию типа задания
  static IconData getTaskIcon(String typeName) {
    return taskTypes.firstWhere(
      (t) => t["name"] == typeName,
      orElse: () => {"icon": Icons.event_note},
    )["icon"] as IconData;
  }

  // Получить иконку по названию типа события
  static IconData getEventIcon(String typeName) {
    return eventTypes.firstWhere(
      (e) => e["name"] == typeName,
      orElse: () => {"icon": Icons.event_note},
    )["icon"] as IconData;
  }
}
