import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();

  User? get user => _user;

  UserProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<void> setUser(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> fetchUserProfile(String token) async {
    try {
      _user = await _apiService.getUserProfile(token);
      notifyListeners();
    } catch (e) {
      print('Failed to load user profile: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    if (_user != null) {
      try {
        final response = await _apiService.updateUserProfile(updatedUser, _user!.token);
        if (response.statusCode == 200) {
          _user = User.fromJson(jsonDecode(response.body));
          _user!.token = updatedUser.token;
          notifyListeners();
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (e) {
        print('Failed to update profile: $e');
      }
    }
  }

  void setFcmToken(String fcmToken) {
    user!.fcmToken = fcmToken;
  }

  Future<bool> changePassword(String token, String oldPassword, String newPassword) async {
    if (_user != null) {
      try {
        final response = await _apiService.changePassword(token, _user!.id, oldPassword, newPassword);
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print('Failed to change password: $e');
        return false;
      }
    }
    return false;
  }
}
