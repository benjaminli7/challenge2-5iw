import 'package:flutter/material.dart';
import 'package:frontend/shared/models/settings.dart';
import 'package:frontend/shared/services/admin_service.dart';

class SettingsProvider with ChangeNotifier {
  final AdminService _configService = AdminService();

  Settings _settings = Settings(
    weatherAPI: false,
    googleAPI: false,
  );

  Settings get settings => _settings;

  SettingsProvider() {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    final response = await _configService.getSettings();
    _settings = response;
    notifyListeners();
  }

  void updateSettings(String token, Settings settings) {
    _configService.updateSettings(token, settings);
    // if done successfully, update local settings
    _settings.weatherAPI = settings.weatherAPI;
    _settings.googleAPI = settings.googleAPI;
    notifyListeners();
  }
}
