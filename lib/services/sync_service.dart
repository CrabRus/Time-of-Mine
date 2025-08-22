import 'package:collection/collection.dart'; // для firstWhereOrNull
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/services/firestore_service.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/models/event.dart';

class SyncService {
  /// Выгрузить все локальные изменения в облако
  static Future<void> uploadAll() async {
    // --- Tasks ---
    final tasks = await LocalStorageService.getAllTasks();
    final unsyncedTasks = tasks.where((t) => !t.isSynced).toList();
    if (unsyncedTasks.isNotEmpty) {
      await FirestoreService.uploadTasks(unsyncedTasks);
      for (var t in unsyncedTasks) {
        await LocalStorageService.updateTask(t.copyWith(isSynced: true));
      }
    }

    // --- Events ---
    final events = await LocalStorageService.getAllEvents();
    final unsyncedEvents = events.where((e) => !e.isSynced).toList();
    if (unsyncedEvents.isNotEmpty) {
      await FirestoreService.uploadEvents(unsyncedEvents);
      for (var e in unsyncedEvents) {
        await LocalStorageService.updateEvent(e.copyWith(isSynced: true));
      }
    }
    SyncState.markSynced();
  }

  /// Загрузить данные из облака в приложение
  static Future<void> downloadAll() async {
    // --- Tasks ---
    final cloudTasks = await FirestoreService.downloadTasks();
    final localTasks = await LocalStorageService.getAllTasks();

    for (var c in cloudTasks) {
      final Task? local = localTasks.firstWhereOrNull((l) => l.id == c.id);

      if (local == null) {
        // новый элемент — добавляем
        await LocalStorageService.addTask(c.copyWith(isSynced: true));
      } else if (c.updatedAt.isAfter(local.updatedAt)) {
        // существующий — обновляем
        await LocalStorageService.updateTask(c.copyWith(isSynced: true));
      }
    }

    // --- Events ---
    final cloudEvents = await FirestoreService.downloadEvents();
    final localEvents = await LocalStorageService.getAllEvents();

    for (var c in cloudEvents) {
      final Event? local = localEvents.firstWhereOrNull((l) => l.id == c.id);

      if (local == null) {
        await LocalStorageService.addEvent(c.copyWith(isSynced: true));
      } else if (c.updatedAt.isAfter(local.updatedAt)) {
        await LocalStorageService.updateEvent(c.copyWith(isSynced: true));
      }
    }

    SyncState.markSynced();
  }

  /// Статистика локальных и облачных данных
  static Future<Map<String, dynamic>> getStats() async {
    final localTasks = await LocalStorageService.getAllTasks();
    final localEvents = await LocalStorageService.getAllEvents();

    final cloudTasks = await FirestoreService.downloadTasks();
    final cloudEvents = await FirestoreService.downloadEvents();

    return {
      "local": {
        "tasks": localTasks.length,
        "events": localEvents.length,
        "unsynced":
            localTasks.where((t) => !t.isSynced).length +
            localEvents.where((e) => !e.isSynced).length,
      },
      "cloud": {"tasks": cloudTasks.length, "events": cloudEvents.length},
    };
  }
}

class SyncState {
  static DateTime? lastSync;

  /// Ставим время последней успешной синхронизации
  static void markSynced() {
    lastSync = DateTime.now();
  }

  /// Проверяем, было ли недавно (например, в последние 5 минут)
  static bool get shouldShowRefreshHint {
    if (lastSync == null) return false;
    final difference = DateTime.now().difference(lastSync!);
    return difference.inMinutes <
        5; // показываем подсказку, если синхронизация < 5 минут назад
  }
}
