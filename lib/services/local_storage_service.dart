import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_of_mine/models/event.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/services/sync_service.dart';

class LocalStorageService {
  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Пользователь не авторизован");
    }
    return user.uid;
  }
  // static String get _uid => 'test_uid'; // только на время тестов


  // ----------------- TASKS -----------------
  static Future<void> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    tasks.add(task);
    final jsonList = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_tasksKey, jsonList);
  }

  static Future<void> updateTask(Task updatedTask) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      final jsonList = tasks.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_tasksKey, jsonList);
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    final jsonList = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_tasksKey, jsonList);
  }

  static Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_tasksKey) ?? [];
    return jsonList.map((json) => Task.fromMap(jsonDecode(json))).toList();
  }

  // ----------------- EVENTS -----------------
  static Future<void> addEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    events.add(event);
    final jsonList = events.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }

  static Future<void> updateEvent(Event updatedEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      final jsonList = events.map((e) => jsonEncode(e.toMap())).toList();
      await prefs.setStringList(_eventsKey, jsonList);
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAllEvents();
    events.removeWhere((e) => e.id == eventId);
    final jsonList = events.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }

  static Future<List<Event>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_eventsKey) ?? [];
    return jsonList.map((json) => Event.fromMap(jsonDecode(json))).toList();
  }

  // ----------------- HELPERS -----------------
  static String get _tasksKey => 'tasks_$_uid';
  static String get _eventsKey => 'events_$_uid';

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_eventsKey);
    SyncState.markSynced();
  }

  // ----------------- SETTINGS -----------------
  static const String _themeKey = 'theme_dark';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _calendarHolidaysKey = 'calendar_show_holidays';

  // Тема
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Уведомления
  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Календарь: показывать праздники
  static Future<void> setShowHolidays(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarHolidaysKey, value);
  }

  static Future<bool> getShowHolidays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_calendarHolidaysKey) ?? true;
  }
}
