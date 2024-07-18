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
    _setLoading(true);
    _users = await _adminService.fetchUsers(token);
    _setLoading(false);
  }

  Future<void> deleteUser(String token, int userId) async {
    await _adminService.deleteUser(token, userId);
    _users.removeWhere((user) => user.email == userId);
    _notifyListenersDeferred();
  }

  Future<void> upgradeAdmin(String token, int userId) async {
    await _adminService.upgradeAdmin(token, userId);
    _notifyListenersDeferred();
  }

  Future<void> fetchHikesNoValidate(String token) async {
    _setLoading(true);
    _hikes = await _adminService.fetchHikesNoValidate(token);
    _setLoading(false);
  }

  Future<void> validateHike(String token, int hikeId) async {
    await _adminService.validateHike(token, hikeId);
    _hikes.removeWhere((hike) => hike.id == hikeId);
    _notifyListenersDeferred();
  }
  Future<void> deleteHike(String token, int hikeId) async {
    await _adminService.deleteHike(token, hikeId);
    _users.removeWhere((hike) => hike.id == hikeId);
    _notifyListenersDeferred();
  }
  void _setLoading(bool value) {
    _loading = value;
    _notifyListenersDeferred();
  }

  void _notifyListenersDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> fetchGroups(String token) async {
    _loading = true;
    notifyListeners();

    try {
      _groups = await _adminService.fetchGroups(token);

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
