import 'dart:convert';

import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String url = 'http://10.213.255.234:8080';

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

      List<dynamic> hikesJson= json.decode(response.body);
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
}
