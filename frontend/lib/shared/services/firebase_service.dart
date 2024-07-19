import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirebaseService {

  final _firebaseMessaging = FirebaseMessaging.instance;

  GoRouter? _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<String?> initNotifications() async {

    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    return fCMToken;
  }

  void handleMessage(RemoteMessage? message) {

    if (message == null) return;

    final data = message.data;


    if (data['route'] != null) {

      _router?.go(data['route']!);
    }
  }

}
