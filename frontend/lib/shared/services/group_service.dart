import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/group.dart';


class GroupService {
  static const String baseUrl = 'http://10.213.255.234:8080/groups';

  Future<http.Response> createGroup(Map<String, dynamic> groupData, hikeId, userId, token) async {
    final url = Uri.parse('$baseUrl');
    final isPrivate = groupData['groupType']=='Private'? true : false;
    print('groupData');
    print(groupData);
    final dateStart = groupData['hikeDate'].toString();

    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'hikeId': hikeId,
        'Start_date': groupData['hikeDate'],
        'IsPrivate': isPrivate,
        'Difficulty': groupData['difficulty'],
        'Organizer_id' : userId,
      }),
    );

    return response;
  }
}


