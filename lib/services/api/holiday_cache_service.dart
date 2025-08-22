import 'package:time_of_mine/models/event.dart';

class HolidayCacheService {
  static final HolidayCacheService _instance = HolidayCacheService._internal();
  factory HolidayCacheService() => _instance;
  HolidayCacheService._internal();

  final Map<DateTime, List<Event>> _cache = {};

  List<Event> getHolidaysForDay(DateTime day) {
    final key = _normalizeDate(day);
    return _cache[key] ?? [];
  }

  void saveHolidays(List<Event> holidays) {
    for (var event in holidays) {
      final key = _normalizeDate(event.dateTime!);
      _cache.putIfAbsent(key, () => []);
      if (!_cache[key]!.any((e) => e.id == event.id)) {
        _cache[key]!.add(event);
      }
    }
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
