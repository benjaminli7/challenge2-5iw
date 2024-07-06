import 'package:flutter/material.dart';
import 'package:frontend/shared/models/settings.dart';

class SettingsProvider with ChangeNotifier {
  Settings _settings = Settings(weatherAPI: true); // Default value

  Settings get settings => _settings;

  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  void updateWeatherAPI(bool value) {
    _settings.weatherAPI = value;
    notifyListeners();
  }

  void clearSettings() {
    _settings = Settings(weatherAPI: true);
    notifyListeners();
  }
}
