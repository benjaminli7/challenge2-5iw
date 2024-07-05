import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/group.dart';

class GroupService {
  static const String baseUrl = 'http://192.168.1.110:8080';

  Future<http.Response> createGroup(Map<String, dynamic> groupData, hikeId, userId, token) async {
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

  Future<List<Group>> fetchMyGroups(String token, int userId) async {
    final url = Uri.parse('$baseUrl/groups/user/$userId');

    final response = await http.get(

      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> groupList = json.decode(response.body);
      print(groupList);
      return groupList.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load groups');
    }
  }
}
