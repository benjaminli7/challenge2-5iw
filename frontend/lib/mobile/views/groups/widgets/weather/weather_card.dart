import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:lottie/lottie.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;

  const WeatherCard({super.key, required this.weather});

  String _getAnimationForWeather() {
    if (weather.weatherMain!.toLowerCase().contains('cloud')) {
      return 'assets/cloud.json';
    } else if (weather.weatherMain!.toLowerCase().contains('rain')) {
      return 'assets/rain.json';
    } else if (weather.weatherMain!.toLowerCase().contains('thunder')) {
      return 'assets/thunder.json';
    } else {
      return 'assets/sun.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    String animationAsset = _getAnimationForWeather();

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            _getFormattedDate(weather.date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Lottie.asset(animationAsset, width: 100, height: 100),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.thermostat, size: 24),
              const SizedBox(width: 4),
              Text(
                '${weather.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A'} °C',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.air, size: 24),
              const SizedBox(width: 4),
              Text(
                '${weather.windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return 'Date N/A';
    // Format the date to be more readable Monday, 1 January 2021
    return DateFormat.yMMMMd('en_US').format(date);
  }
}
