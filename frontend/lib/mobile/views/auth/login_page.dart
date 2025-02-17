import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/shared/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;
  String _fcmToken = "";

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final String? token = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (token != null) {
      Map<String, dynamic> parseJwt = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))),
      );
      if (parseJwt['verified'] == true) {
        Provider.of<UserProvider>(context, listen: false).setUser(
          User(
              id: parseJwt['sub'],
              email: parseJwt['email'],
              username: parseJwt['username'],
              password: "",
              token: token,
              role: parseJwt['roles'],
              isVerified: parseJwt['verified'],
              profileImage: parseJwt['profile_image'],
              fcmToken: parseJwt['fcm_token'] ?? ""),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _fcmToken = prefs.getString('fcmToken')!;

        if ((parseJwt['fcm_token'] == null || parseJwt['fcm_token'] == "") &&
                _fcmToken != "" ||
            parseJwt['fcm_token'] != _fcmToken) {
          final response = await _apiService.setFcmToken(
              Provider.of<UserProvider>(context, listen: false).user!.id,
              _fcmToken,
              Provider.of<UserProvider>(context, listen: false).user!.token);

          if (response.statusCode == 200) {
            Provider.of<UserProvider>(context, listen: false)
                .setFcmToken(_fcmToken);
          }
        }
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.logInSuccess,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        GoRouter.of(context).go('/explore');
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.logInFailure,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.logInFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser);

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.logInFailureGoogle2,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? token = await _apiService.login(
        googleUser.email,
        "",
        isGoogle: true,
      );
      Map<String, dynamic> parseJwt = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token!.split('.')[1]))),
      );
      if (parseJwt['verified'] == true) {
        Provider.of<UserProvider>(context, listen: false).setUser(
          User(
              id: parseJwt['sub'],
              email: parseJwt['email'],
              username: parseJwt['username'],
              password: "",
              token: token,
              role: parseJwt['roles'],
              isVerified: parseJwt['verified'],
              fcmToken: parseJwt['fcm_token']),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _fcmToken = prefs.getString('fcmToken')!;

        if ((parseJwt['fcm_token'] == null || parseJwt['fcm_token'] == "") &&
                _fcmToken != "" ||
            parseJwt['fcm_token'] != _fcmToken) {
          final response = await _apiService.setFcmToken(
              Provider.of<UserProvider>(context, listen: false).user!.id,
              _fcmToken,
              Provider.of<UserProvider>(context, listen: false).user!.token);
          if (response.statusCode == 200) {
            Provider.of<UserProvider>(context, listen: false)
                .setFcmToken(_fcmToken);
          }
        }

        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.connectedGoogle,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        GoRouter.of(context).go('/explore');
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.notVerified,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
    } catch (e) {
      print(e);
      // Fluttertoast.showToast(
      //   msg: AppLocalizations.of(context)!.logInFailureGoogle3,
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.red,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isGoogleActivated = settingsProvider.settings.googleAPI;
    return Scaffold(
      appBar: const NavBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.login,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                CustomTextField(
                  controller: _passwordController,
                  labelText: AppLocalizations.of(context)!.password,
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(AppLocalizations.of(context)!.login,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                isGoogleActivated
                    ? ElevatedButton(
                        onPressed: _googleLogin,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/google.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.connectedGoogle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 0,
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
                  child: Text(AppLocalizations.of(context)!.notAccount),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
