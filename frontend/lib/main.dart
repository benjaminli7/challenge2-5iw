import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/mobile/mobile_app.dart';
import 'package:frontend/shared/services/firebase_service.dart';
import 'package:frontend/web/web_app.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/firebase_options.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsBinding is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
    // Handle error loading dotenv file (optional)
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService().initNotifications();
  final token = await FirebaseMessaging.instance.getToken();

  prefs.setString('fcmToken', token!);
  if (prefs.containsKey('fcmToken')) {
    print('FCM Token: ${prefs.getString('fcmToken')}');
  }

  setupFirebaseMessagingHandlers();

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: kIsWeb
          ? const MyWebApp()
          : MyMobileApp(initialMessage: initialMessage),
    ),
  );
}

void setupFirebaseMessagingHandlers() {
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('FCM MESSAGE onMessage: $message');
  //   FirebaseService().handleMessage(message);

  //   // push to the mobile app view
  // });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('FCM MESSAGE onMessageOpenedApp: $message');
    // FirebaseService().handleMessage(message);

    final routeName = message.data['route'];
    if (routeName != null) {
      GoRouter.of(navigatorKey.currentState!.context).push('/test');
    }
    // push to the mobile app view
  });

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('FCM MESSAGE onBackgroundMessage: $message');
//   FirebaseService().handleMessage(message);
// }
