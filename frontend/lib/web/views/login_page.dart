import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/shared/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _login() async {
    final String? token = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (token != null) {
      Map<String, dynamic> parseJwt = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))),
      );
      print('parseJwt, $parseJwt');
      print(token);
      if (parseJwt['roles'] == 'admin' && parseJwt['verified'] == true) {
        Provider.of<UserProvider>(context, listen: false).setUser(
          User(
              id: parseJwt['sub'],
              email: parseJwt['email'],
              username: parseJwt['username'],
              password: "",
              token: token,
              role: parseJwt['roles'],
              isVerified: parseJwt['verified']),
        );

        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        GoRouter.of(context).go('/users');
      } else {
        Fluttertoast.showToast(
          msg: 'Vous n\'avez pas les droits d\'accès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // Handle login error
      Fluttertoast.showToast(
        msg: 'Login failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
            ),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
