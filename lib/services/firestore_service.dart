  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:time_of_mine/models/event.dart';
  import 'package:time_of_mine/models/task.dart';
  import 'package:time_of_mine/services/sync_service.dart';

  class FirestoreService {
    static final _db = FirebaseFirestore.instance;

    static String get _uid {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Пользователь не авторизован");
      return user.uid;
    }

    // ----------------- TASKS -----------------
    static Future<void> uploadTasks(List<Task> tasks) async {
      final batch = _db.batch();
      final ref = _db.collection('users').doc(_uid).collection('tasks');

      for (var task in tasks) {
        final doc = ref.doc(task.id);
        batch.set(doc, task.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    }

    static Future<List<Task>> downloadTasks() async {
      final snapshot = await _db.collection('users').doc(_uid).collection('tasks').get();
      return snapshot.docs.map((d) => Task.fromMap(d.data())).toList();
    }

    // ----------------- EVENTS -----------------
    static Future<void> uploadEvents(List<Event> events) async {
      final batch = _db.batch();
      final ref = _db.collection('users').doc(_uid).collection('events');

      for (var event in events) {
        final doc = ref.doc(event.id);
        batch.set(doc, event.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    }

    static Future<List<Event>> downloadEvents() async {
      final snapshot = await _db.collection('users').doc(_uid).collection('events').get();
      return snapshot.docs.map((d) => Event.fromMap(d.data())).toList();
    }

    // ----------------- DELETE ALL CLOUD DATA -----------------
    static Future<void> deleteAllCloudData() async {
      final batch = _db.batch();

      // Удаляем все задачи
      final tasksSnapshot = await _db.collection('users').doc(_uid).collection('tasks').get();
      for (var doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Удаляем все события
      final eventsSnapshot = await _db.collection('users').doc(_uid).collection('events').get();
      for (var doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      SyncState.markSynced();
    }
  }
