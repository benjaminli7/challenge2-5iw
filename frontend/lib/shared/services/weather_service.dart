import 'package:weather/weather.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config_service.dart';

class WeatherService {
  String baseUrl = ConfigService.baseUrl;
  late WeatherFactory _weatherFactory;

  WeatherService() {
    final String? apiKey = dotenv.env['WEATHER_API_KEY'];

    _weatherFactory = WeatherFactory(apiKey!);
  }

  Future<List<Weather>> getWeather(Group group) async {
    try {
   
      double latitude = double.parse(group.hike.lat);
      double longitude = double.parse(group.hike.lng);
    

      // Fetch 5-day forecast data
      List<Weather> forecast = await _weatherFactory.fiveDayForecastByLocation(
          latitude, longitude
      );

      // Filter to keep only the first forecast of each day
      forecast = _filterDailyForecasts(forecast);

      // Ensure the list contains exactly 5 entries
      if (forecast.length > 5) {
        forecast = forecast.sublist(0, 5);
      }

      return forecast;
    } catch (e) {
      rethrow;
    }
  }

  List<Weather> _filterDailyForecasts(List<Weather> forecast) {
    Map<DateTime, Weather> dailyForecasts = {};

    for (Weather weather in forecast) {
      DateTime date =
          DateTime(weather.date!.year, weather.date!.month, weather.date!.day);

      if (!dailyForecasts.containsKey(date)) {
        dailyForecasts[date] = weather;
      }
    }

    return dailyForecasts.values.toList();
  }
}
