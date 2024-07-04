import 'dart:convert';

import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String url = 'http://192.168.1.94:8080';

  Future<List<User>> fetchUsers(String token) async {
    print('fetchUsers token: $token');
    final response = await http.get(
      Uri.parse('$url/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Parsing the JSON assuming the response contains an object with a "users" key
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
      Uri.parse('$url/users/$userId'),
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
      Uri.parse('$url/users/${userId}/role'),
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
      Uri.parse('$url/hikes/notValidated'),
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
      Uri.parse('$url/hikes/${hikeId}/validate'),
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

  Future<List<Group>> fetchGroups(String token) async {
    final response = await http.get(
      Uri.parse('$url/groups'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      // Si data est une liste
      if (data is List) {
        return data.map((json) => Group.fromJson(json)).toList();
      }
      // Si data est une map contenant la clé 'groups'
      else if (data is Map<String, dynamic> && data.containsKey('groups')) {
        List<dynamic> groupsJson = data['groups'];
        return groupsJson.map((json) => Group.fromJson(json)).toList();
      }
      else {
        throw Exception('Unexpected JSON structure: $data');
      }
    } else {
      print('Failed to load groups: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to load groups: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> deleteGroup(String token, int groupId) async {
    final response = await http.delete(
      Uri.parse('$url/groups/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete group');
    }
  }

}
