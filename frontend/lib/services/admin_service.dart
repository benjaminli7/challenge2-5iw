import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

class AdminService {
  static const String url = 'https://10.49.121.62:8080/users';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
