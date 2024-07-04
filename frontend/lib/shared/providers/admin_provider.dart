import 'package:flutter/material.dart';
import 'package:frontend/shared/services/admin_service.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/models/group.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  List<Hike> _hikes = [];
  List<Group> _groups = [];
  bool _loading = false;

  List<User> get users => _users;
  List<Hike> get hikes => _hikes;
  List<Group> get groups => _groups;
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

  Future<void> fetchGroups(String token) async {
    _loading = true;
    notifyListeners();

    try {
      _groups = await _adminService.fetchGroups(token);
      print('Fetched groups: $_groups'); // Debugging
    } catch (e) {
      print('Error fetching groups: $e');

    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String token, int groupId) async {
    await _adminService.deleteGroup(token, groupId);
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }
}
