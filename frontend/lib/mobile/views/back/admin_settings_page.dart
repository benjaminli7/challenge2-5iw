import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late SettingsProvider _settingsProvider;
  late bool _isWeatherApiEnabled;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _isWeatherApiEnabled = _settingsProvider.settings.weatherAPI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                const Text(
                  'Weather API',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _isWeatherApiEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _isWeatherApiEnabled = value;
                    });
                    _settingsProvider.updateWeatherAPI(value);
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
