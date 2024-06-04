import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/models/user.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  bool _loading = false;

  List<User> get users => _users;
  bool get loading => _loading;

  final AdminService _adminService = AdminService();

  Future<void> fetchUsers(String token) async {
    _loading = true;
    notifyListeners();

    _users = await _adminService.fetchUsers(token);

    _loading = false;
    notifyListeners();
  }

  Future<void> deleteUser(String token, int userId) async {
    await _adminService.deleteUser(token, userId);
    _users.removeWhere((user) => user.email == userId);
    notifyListeners();
  }

  Future<void> updateUser(String token, User user) async {
    await _adminService.updateUser(token, user);
    int index = _users.indexWhere((u) => u.email == user.email);
    if (index != -1) {
      _users[index] = user;
      notifyListeners();
    }
  }
}
