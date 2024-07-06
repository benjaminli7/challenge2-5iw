import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/mobile/mobile_app.dart';
import 'package:frontend/web/web_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
    // Handle error loading dotenv file (optional)
  }

  runApp(kIsWeb ? const MyWebApp() : const MyMobileApp());
}
