import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/models/event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

    // Включаем тестовый режим
  AuthHelper.setTestMode(true);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService - Tasks', () {
    test('should add and retrieve a task', () async {
      final task = Task(id: '1', title: 'Test Task');
      await LocalStorageService.addTask(task);

      final tasks = await LocalStorageService.getAllTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
    });

    test('should update a task', () async {
      final task = Task(id: '1', title: 'Old Task');
      await LocalStorageService.addTask(task);

      final updatedTask = task.copyWith(title: 'Updated Task');
      await LocalStorageService.updateTask(updatedTask);

      final tasks = await LocalStorageService.getAllTasks();
      expect(tasks.first.title, 'Updated Task');
    });

    test('should delete a task', () async {
      final task = Task(id: '1', title: 'Task to delete');
      await LocalStorageService.addTask(task);

      await LocalStorageService.deleteTask('1');

      final tasks = await LocalStorageService.getAllTasks();
      expect(tasks.isEmpty, true);
    });
  });

  group('LocalStorageService - Events', () {
    test('should add and retrieve an event', () async {
      final event = Event(id: 'e1', title: 'Test Event');
      await LocalStorageService.addEvent(event);

      final events = await LocalStorageService.getAllEvents();
      expect(events.length, 1);
      expect(events.first.title, 'Test Event');
    });

    test('should update an event', () async {
      final event = Event(id: 'e1', title: 'Old Event');
      await LocalStorageService.addEvent(event);

      final updatedEvent = event.copyWith(title: 'Updated Event');
      await LocalStorageService.updateEvent(updatedEvent);

      final events = await LocalStorageService.getAllEvents();
      expect(events.first.title, 'Updated Event');
    });

    test('should delete an event', () async {
      final event = Event(id: 'e1', title: 'Event to delete');
      await LocalStorageService.addEvent(event);

      await LocalStorageService.deleteEvent('e1');

      final events = await LocalStorageService.getAllEvents();
      expect(events.isEmpty, true);
    });
  });

  group('LocalStorageService - Settings', () {
    test('should set and get dark mode', () async {
      await LocalStorageService.setDarkMode(true);
      final isDark = await LocalStorageService.getDarkMode();
      expect(isDark, true);
    });

    test('should set and get notifications setting', () async {
      await LocalStorageService.setNotificationsEnabled(false);
      final enabled = await LocalStorageService.getNotificationsEnabled();
      expect(enabled, false);
    });

    test('should set and get show holidays setting', () async {
      await LocalStorageService.setShowHolidays(false);
      final show = await LocalStorageService.getShowHolidays();
      expect(show, false);
    });
  });

  group('LocalStorageService - Clear Data', () {
    test('should clear user data', () async {
      await LocalStorageService.addTask(Task(id: '1', title: 'Task'));
      await LocalStorageService.addEvent(Event(id: 'e1', title: 'Event'));

      await LocalStorageService.clearUserData();

      final tasks = await LocalStorageService.getAllTasks();
      final events = await LocalStorageService.getAllEvents();

      expect(tasks.isEmpty, true);
      expect(events.isEmpty, true);
    });
  });
}