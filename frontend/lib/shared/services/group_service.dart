import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/group.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroupService {
  static String baseUrl = dotenv.env['BASE_URL']!;

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

  Future<List<Group>> fetchHikeGroups(
      String token, int hikeId, int userId) async {
    final url = Uri.parse('$baseUrl/groups/hike/$hikeId/$userId');

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

  Future<void> joinGroup(String token, int groupId, int userId) async {
    final url = Uri.parse('$baseUrl/groups/join');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'groupId': groupId,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to join the group');
    }
  }
}
