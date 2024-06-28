import 'package:flutter/material.dart';
import 'package:frontend/shared/services/admin_service.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  List<Hike> _hikes = [];
  bool _loading = false;

  List<User> get users => _users;
  List<Hike> get hikes => _hikes;
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

  Future<void> upgradeAdmin(String token, int userId) async {
    await _adminService.upgradeAdmin(token, userId);

    notifyListeners();

  }

  Future<void> fetchHikesNoValidate(String token) async {
    _loading = true;
    notifyListeners();

    _hikes = await _adminService.fetchHikesNoValidate(token);

    _loading = false;
    notifyListeners();
  }

  Future<void> validateHike(String token, int hikeId) async {
    await _adminService.validateHike(token, hikeId);
    _hikes.removeWhere((hike) => hike.id == hikeId);
    notifyListeners();
  }
}
