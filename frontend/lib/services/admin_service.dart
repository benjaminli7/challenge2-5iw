import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';


class AdminService {
  static const String url = 'http://10.33.0.65:8080/users';

  Future<List<User>> fetchUsers(String token) async {


    final response = await http.get(
      Uri.parse(url),
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
      print('Failed to load users: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to load users: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$url/$userId'),
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> updateUser(String token, User user) async {
    final response = await http.put(
      Uri.parse('$url/${user.email}'),
      headers: {
        'Cookie': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
}
