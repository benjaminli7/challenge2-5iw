import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/models/user.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  bool _loading = false;

  List<User> get users => _users;
  bool get loading => _loading;

  final AdminService _adminService = AdminService();

  Future<void> fetchUsers() async {
    _loading = true;
    notifyListeners();

    _users = await _adminService.fetchUsers();

    _loading = false;
    notifyListeners();
  }
}
