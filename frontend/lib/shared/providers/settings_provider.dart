import 'package:flutter/material.dart';
import 'package:frontend/shared/models/settings.dart';

class SettingsProvider with ChangeNotifier {
  Settings _settings = Settings(weatherAPI: true, googleAuth: true);

  Settings get settings => _settings;

  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  void updateWeatherAPI(bool value) {
    _settings.weatherAPI = value;
    notifyListeners();
  }

  void updateGoogleAuth(bool value) {
    _settings.googleAuth = value;
    notifyListeners();
  }

  void clearSettings() {
    _settings = Settings(weatherAPI: true, googleAuth: true);
    notifyListeners();
  }
}
