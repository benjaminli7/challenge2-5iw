import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class FirebaseService {
// create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

//function to initialise the notifications

  Future<String?> initNotifications() async {
    //request permission
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    // print('FCM Token: $fCMToken');
    return fCMToken;
  }

  // Function to handle received notifications
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // Navigate based on notification data
    final data = message.data;
    if (data['route'] != null) {
      //
    }
  }

//function to initialise foreground and background settings
}
