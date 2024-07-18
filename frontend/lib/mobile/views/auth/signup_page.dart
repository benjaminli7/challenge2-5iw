import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/shared/widgets/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _signup() async {
    final response = await _apiService.signup(
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
      _image,
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.signUpSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      GoRouter.of(context).go('/login');
    } else if (response.statusCode == 400) {
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.signUpFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                AppLocalizations.of(context)!.signUp,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
              ),
              CustomTextField(
                controller: _usernameController,
                labelText: AppLocalizations.of(context)!.username,
              ),
              CustomTextField(
                controller: _passwordController,
                labelText: AppLocalizations.of(context)!.password,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _image == null
                  ?  Text(AppLocalizations.of(context)!.noAvatar)
                  : Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child:  Text(AppLocalizations.of(context)!.uploadAvatar),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child:  Text(
                  AppLocalizations.of(context)!.signUp,

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  GoRouter.of(context).go('/login');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child:  Text(AppLocalizations.of(context)!.alreadyRegister),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
