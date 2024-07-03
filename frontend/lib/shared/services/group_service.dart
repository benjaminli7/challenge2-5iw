import 'dart:convert';

import 'package:http/http.dart' as http;

class GroupService {
  static const String baseUrl = 'http://192.168.1.19:8080';

  Future<http.Response> createGroup(
      Map<String, dynamic> groupData, hikeId, userId, token) async {
    final url = Uri.parse('$baseUrl/groups');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'hike_id': hikeId,
        'start_date': groupData['hikeDate'],
        'organizer_id': userId,
      }),
    );

    return response;
  }
}
