import 'package:weather/weather.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  late WeatherFactory _weatherFactory;

  WeatherService() {
    final String? apiKey = dotenv.env['WEATHER_API_KEY'];
    print('Weather API key: $apiKey');

    _weatherFactory = WeatherFactory(apiKey!);
  }

  Future<List<Weather>> getWeather(Group group) async {
    try {
      // Fetch GPX data from the provided URL
      final response = await http
          .get(Uri.parse('${dotenv.env['BASE_URL']}${group.hike.gpxFile}'));
      final points = await HikeProvider().parseGPX(response.body);

      // Extract coordinates from the first point
      final point = points.first;

      // Fetch 5-day forecast data
      List<Weather> forecast = await _weatherFactory.fiveDayForecastByLocation(
          point.latitude, point.longitude);

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
    // Map to store daily forecasts based on date
    Map<DateTime, Weather> dailyForecasts = {};

    // Iterate through all forecasts and keep only the first one for each day
    for (Weather weather in forecast) {
      // Extract the date without time (since time will vary for different forecasts in the same day)
      DateTime date =
          DateTime(weather.date!.year, weather.date!.month, weather.date!.day);

      // Only add the forecast if it's the first one for that day
      if (!dailyForecasts.containsKey(date)) {
        dailyForecasts[date] = weather;
      }
    }

    // Convert map values (daily forecasts) to a list and return
    return dailyForecasts.values.toList();
  }
}
