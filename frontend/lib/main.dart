import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/mobile/mobile_app.dart';
import 'package:frontend/shared/services/firebase_service.dart';
import 'package:frontend/web/web_app.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('fcmToken')) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    var token = await FirebaseService().initNotifications();
    prefs.setString('fcmToken', token!);
  }
  if (prefs.containsKey('fcmToken')) {
    print('FCM Token: ${prefs.getString('fcmToken')}');
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
    // Handle error loading dotenv file (optional)
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: kIsWeb ? const MyWebApp() : const MyMobileApp(),
    ),
  );
}
