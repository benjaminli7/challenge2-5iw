import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/mobile/mobile_app.dart';
import 'package:frontend/web/web_app.dart';

void main() {
  if (kIsWeb) {
    runApp(MyWebApp());
  } else {
    runApp(MyMobileApp());
  }
}
