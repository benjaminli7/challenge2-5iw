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
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _login() async {
    final String? token = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return; // Check if the widget is still mounted

    if (token != null) {
      print(token);
      Map<String, dynamic> parseJwt = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))),
      );

      Provider.of<UserProvider>(context, listen: false).setUser(
        User(
            id: parseJwt['sub'],
            email: parseJwt['email'],
            password: "",
            token: token,
            role: parseJwt['roles'],
            isVerified: parseJwt['verified']),
      );
      //print user info
      Fluttertoast.showToast(
        msg: 'Login successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      GoRouter.of(context).go('/explore');
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

  void _googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(
            msg: 'Failed to connect with Google',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = Fluttertoast.showToast(
        msg: 'Connected with Google',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      GoRouter.of(context).go('/explore');
    } catch (e) {
      // Handle login error
      Fluttertoast.showToast(
        msg: 'Failed to connect with Google',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Failed to connect with Google');
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
            ElevatedButton(
              onPressed: _googleLogin,
              child: const Text('Sign in with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/signup');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: const Text('No account yet? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
