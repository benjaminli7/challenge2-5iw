import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:frontend/shared/services/api_service.dart';
import 'dart:convert';

class ValidatePage extends StatefulWidget {
  final String token;

  const ValidatePage({super.key, required this.token});

  @override
  _ValidatePageState createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isValidated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateAccount();
  }

  Future<void> _validateAccount() async {
    try {
      print('Attempting to validate account with token: ${widget.token}');
      final response = await _apiService.validateAccount(widget.token);
      print('Response received with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Response body: $responseBody');


          setState(() {
            _isValidated = true;
          });
          Fluttertoast.showToast(msg: 'Account validated successfully');

      } else {
        setState(() {
          _errorMessage = 'Validation failed: ${response.reasonPhrase}';
        });
        print('Error: Validation failed with status code ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Validation failed: $error';
      });
      print('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Validation process completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _isValidated
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Account validated successfully',
              style: TextStyle(fontSize: 18),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Validation failed',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
