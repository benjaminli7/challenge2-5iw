import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _changePassword() async {
    final response = await _apiService.resetPassword(
        _passwordController.text
    );

    if (!mounted) return; // Check if the widget is still mounted

    if (response.statusCode == 200) {
      // Handle successful signup
      print('Email successful');
      Fluttertoast.showToast(
        msg: 'Email successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushReplacementNamed(context, '/resetPassword');
    } else {
      // Handle signup error
      Fluttertoast.showToast(
        msg: 'Email failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Email failed');
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
              'Mot de passe oublié',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Email',
            ),

            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Envoyé'),
            ),

          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
