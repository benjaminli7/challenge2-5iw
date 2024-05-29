import 'package:flutter/material.dart';
import 'package:frontend/views/ChangePassword_page.dart';
import 'package:frontend/views/forgetPassword_page.dart';
import 'package:provider/provider.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/home_page.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'LeafMeet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/signup': (context) => const SignupPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/forgetPassword' : (context) => const ForgetPasswordPage(),
          '/resetPassword' : (context) => const ChangePasswordPage(),

        },
      ),
    );
  }
}
