import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/services/api_service.dart';


class UserProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();


  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    if (_user != null) {
      final response = await _apiService.updateUserProfile(updatedUser);
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to update profile');
      }
    }
  }

}


