import 'dart:convert';

import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/settings.dart';

import 'config_service.dart';

class AdminService {

  String baseUrl = ConfigService.baseUrl;

  Future<List<User>> fetchUsers(String token) async {
    print('fetchUsers token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      List<dynamic> usersJson = data['users'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      print(
          'Failed to load users: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception(
          'Failed to load users: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> upgradeAdmin(String token, int userId) async {
    var body = jsonEncode({"role": "admin"});
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<List<Hike>> fetchHikesNoValidate(String token) async {
    print('fetchUsers token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/hikes/notValidated'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> hikesJson = json.decode(response.body);
      print('data: $hikesJson');
      return hikesJson.map((json) => Hike.fromJson(json)).toList();
    } else {
      print(
          'Failed to load hikes: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception(
          'Failed to load hikes: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> validateHike(String token, int hikeId) async {
    var body = jsonEncode({"validated": true});
    final response = await http.patch(
      Uri.parse('$baseUrl/hikes/$hikeId/validate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to validate hike');
    }
  }

  Future<void> deleteHike(String token, int hikeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/hikes/$hikeId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete hike');
    }
  }

  Future<List<Group>> fetchGroups(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if (data is List) {
        return data.map((json) => Group.fromJson(json)).toList();
      } else if (data is Map<String, dynamic> && data.containsKey('groups')) {
        List<dynamic> groupsJson = data['groups'];
        return groupsJson.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected JSON structure: $data');
      }
    } else {
      print(
          'Failed to load groups: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception(
          'Failed to load groups: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> deleteGroup(String token, int groupId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/groups/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete group');
    }
  }

  //route for getSettings and updateSetting
  Future getSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/options'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return Settings.fromJson(data);
    } else {
      print(
          'Failed to load settings: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception(
          'Failed to load settings: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> updateSettings(String token, Settings settings) async {
    var body = jsonEncode(settings.toJson());
    final response = await http.patch(
      Uri.parse('$baseUrl/options'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update settings');
    }
  }
}
