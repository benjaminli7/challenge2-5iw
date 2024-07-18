import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/services/weather_service.dart';
import 'package:frontend/mobile/views/groups/widgets/weather/weather_forecast.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:provider/provider.dart';

// ignore: constant_identifier_names
enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

class WeatherWidget extends StatefulWidget {
  final Group group;

  const WeatherWidget({super.key, required this.group});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    try {
      final ws = WeatherService();
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final useWeatherAPI = settingsProvider.settings.weatherAPI;

      print('Weather API enabled: $useWeatherAPI');

      if (useWeatherAPI) {
        final forecast = await ws.getWeather(widget.group);
        setState(() {
          _data = forecast;
          _state = AppState.FINISHED_DOWNLOADING;
        });
      } else {
        setState(() {
          _state = AppState.NOT_DOWNLOADED;
        });
      }
    } catch (e) {
      setState(() {
        _state = AppState.NOT_DOWNLOADED;
      });
    }
  }

  Widget contentFinishedDownload() {
    return 
    
    WeatherForecast(data: _data);
  }

  Widget contentDownloading() {
    return Container(
      margin: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Fetching Weather...',
            style: TextStyle(fontSize: 20),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 10)),
          ),
        ],
      ),
    );
  }

  Widget contentNotDownloaded() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Weather data could not be fetched.',
          ),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Set a fixed height or adjust as needed
      child: _resultView(),
    );
  }
}
