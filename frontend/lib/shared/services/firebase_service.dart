import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirebaseService {
// create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  GoRouter? _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

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
    // print('FCM MESSAGE: $message.data');
    if (message == null) return;

    // Navigate based on notification data
    final data = message.data;

    // print('Data: $data');

    if (data['route'] != null) {
      // print('From message: ${data['route']}');
      _router?.go(data['route']!);
    }
  }

//function to initialise foreground and background settings
}
