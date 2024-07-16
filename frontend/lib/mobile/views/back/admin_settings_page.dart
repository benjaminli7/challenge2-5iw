import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/settings.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late SettingsProvider _settingsProvider;
  late bool _isWeatherApiEnabled;
  late bool _isGoogleAuthEnabled;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.fetchSettings();
    _isWeatherApiEnabled = _settingsProvider.settings.weatherAPI;
    _isGoogleAuthEnabled = _settingsProvider.settings.googleAPI;

    print('isWeatherApiEnabled: $_isWeatherApiEnabled');
    print('isGoogleAuthEnabled: $_isGoogleAuthEnabled');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                Lottie.asset(
                    _isWeatherApiEnabled
                        ? 'assets/sun.json'
                        : 'assets/thunder.json',
                    width: 80,
                    height: 80),
                const SizedBox(width: 16),
                Switch(
                  value: _isWeatherApiEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _isWeatherApiEnabled = value;
                    });
                    _settingsProvider.updateSettings(
                      context.read<UserProvider>().user!.token,
                      Settings(
                          weatherAPI: value, googleAPI: _isGoogleAuthEnabled),
                    );
                  },
                ),
              ]),
              Row(children: [
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/images/google.svg',
                  height: 50,
                  width: 50,
                ),
                const SizedBox(width: 32),
                Switch(
                  value: _isGoogleAuthEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _isGoogleAuthEnabled = value;
                    });
                    _settingsProvider.updateSettings(
                      context.read<UserProvider>().user!.token,
                      Settings(
                          weatherAPI: _isWeatherApiEnabled, googleAPI: value),
                    );
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
