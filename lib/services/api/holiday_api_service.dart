import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:time_of_mine/models/event.dart';

class HolidayApiService {
  final String? _apiKey = dotenv.env['HOLIDAY_API_KEY'];
  final String? _baseUrl = dotenv.env['BASE_URL'];

  /// Загружает праздники по стране и дате (в free версии всегда прошлый год!)
  Future<List<Event>> fetchHolidays({
    required String country,
    int? year,
    int? month,
    int? day,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key не найден. Проверьте .env: HOLIDAY_API_KEY.');
    }
    if (_baseUrl == null || _baseUrl.isEmpty) {
      throw Exception('BASE_URL не найден. Проверьте .env: BASE_URL.');
    }

    // Бесплатный тариф -> только прошлый год
    final currentYear = DateTime.now().year;
    final safeYear = currentYear - 1;

    final uri = Uri.parse(
      '$_baseUrl?key=$_apiKey&country=$country&year=$safeYear'
      '${month != null ? '&month=$month' : ''}'
      '${day != null ? '&day=$day' : ''}',
    );

    try {
      print('Holiday API request: $uri');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        if (response.statusCode == 402) {
          throw Exception(
            'Бесплатный аккаунт Holiday API позволяет использовать только прошлый год ($safeYear). '
            'Ответ сервера: ${response.body}',
          );
        } else {
          throw Exception(
            'Ошибка API: код ${response.statusCode}, ответ: ${response.body}',
          );
        }
      }

      final data = json.decode(response.body);

      if (data['holidays'] == null || data['holidays'].isEmpty) {
        return [];
      }

      final List<Event> holidays = [];
      final holidaysRaw = data['holidays'];

      if (holidaysRaw is List) {
        // Если API вернул список праздников
        for (var holiday in holidaysRaw) {
          holidays.add(
            Event(
              id: 'holiday_${holiday['date']}_${holiday['name']}',
              title: holiday['name'],
              type: 'Holiday',
              dateTime: DateTime.parse(holiday['date']),
            ),
          );
        }
      } else if (holidaysRaw is Map<String, dynamic>) {
        for (var entry in holidaysRaw.entries) {
          for (var holiday in entry.value) {
            holidays.add(
              Event(
                id: 'holiday_${holiday['date']}_${holiday['name']}',
                title: holiday['name'],
                type: 'Holiday',
                dateTime: DateTime.parse(holiday['date']),
              ),
            );
          }
        }
      } else {
        throw Exception('Неизвестный формат holidays: ${holidaysRaw.runtimeType}');
      }

      return holidays;
    } catch (e) {
      throw Exception('Не удалось загрузить праздники: $e');
    }
  }
}
