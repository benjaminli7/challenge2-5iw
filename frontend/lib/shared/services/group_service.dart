import 'dart:convert';

import 'package:frontend/shared/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/user.dart';
import '../models/group.dart';
import 'config_service.dart';

class GroupService {
  String baseUrl = ConfigService.baseUrl;

  // get a group by id
  Future<Group> getGroupById(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group');
    }
  }

  Future<http.Response> createGroup(Map<String, dynamic> groupData, hikeId,
      userId, token) async {
    final url = Uri.parse('$baseUrl/groups');
    print(groupData['hikeDate']);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'hike_id': hikeId,
        'start_date': groupData['hikeDate'],
        'name': groupData['name'],
        'description': groupData['description'],
        'organizer_id': userId,
        'max_users': groupData['maxUsers'],
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

  Future<List<Group>> fetchHikeGroups(String token, int hikeId,
      int userId) async {
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

  // Add a method to delete a group
  Future<void> deleteGroup(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete the group');
    }
  }

  // fetch group messages
  Future<List<Message>> fetchGroupMessages(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/messages');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messageList = json.decode(response.body);
      print(messageList);
      return messageList.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Group> fetchParticipants(String token, int groupId) async {
    print('fetching participants');
    final url = Uri.parse('$baseUrl/groups/participants/$groupId');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load participants');
    }
  }


  Future<http.Response> deleteUserGroup(String token, int groupId, int userId) async {
    final url = Uri.parse('$baseUrl/groups/user/$userId/$groupId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

}