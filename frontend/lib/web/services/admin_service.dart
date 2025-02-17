import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/user.dart';

import '../../shared/services/config_service.dart';

class AdminService {
  String baseUrl = ConfigService.baseUrl;

  Future<List<User>> fetchUsers(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Cookie': token,
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
      Uri.parse('$baseUrl/$userId'),
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> upgradeAdmin(String token, int userId) async {
    var body = jsonEncode({"role": "admin"});
    final response = await http.patch(
      Uri.parse('$baseUrl/$userId/role'),
      headers: {
        'Cookie': token,
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
}
