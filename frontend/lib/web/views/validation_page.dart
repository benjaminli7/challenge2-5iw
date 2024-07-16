import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:frontend/shared/services/api_service.dart';
class ValidatePage extends StatefulWidget {
  final String token;

  const ValidatePage({super.key, required this.token});

  @override
  _ValidatePageState createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  @override
  void initState() {
    super.initState();
    _validateAccount();
  }
  final ApiService _apiService = ApiService();
  Future<void> _validateAccount() async {
    try {
      final response = await _apiService.validateAccount(widget.token);
      Fluttertoast.showToast(msg: 'Account validated successfully');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Validation failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validate Account'),
      ),
      body: Center(
        child: Text('Validating your account...'),
      ),
    );
  }
}
