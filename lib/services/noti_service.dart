import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "daily_channel_id",
        "Daily noti",
        channelDescription: "Daily noti channel",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleAllNotifications() async {
    final tasks = await LocalStorageService.getAllTasks();
    final events = await LocalStorageService.getAllEvents();

    // Очистим все старые уведомления
    await cancelAllNotifications();

    int id = 0;

    // Для задач
    for (var task in tasks) {
      if (task.deadline != null) {
        await scheduleNotification(
          id: id++,
          title: "Task: ${task.title}",
          body: "Deadline ${task.deadline!.toLocal()}",
          dateTime: task.deadline!,
        );
      }
    }

    // Для событий
    for (var event in events) {
      if (event.dateTime != null) {
        await scheduleNotification(
          id: id++,
          title: "Event: ${event.title}",
          body: "Scheduled for ${event.dateTime!.toLocal()}",
          dateTime: event.dateTime!,
        );
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
