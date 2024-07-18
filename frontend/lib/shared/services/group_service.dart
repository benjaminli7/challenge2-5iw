import 'dart:convert';
import 'dart:io';

import 'package:frontend/shared/models/group_image.dart';
import 'package:frontend/shared/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/group.dart';
import 'config_service.dart';

class GroupService {
  String baseUrl = ConfigService.baseUrl;

  Future<Group> getGroupById(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group');
    }
  }

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
      return messageList.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<List<GroupImage>> fetchGroupImages(String token, int groupId) async {
    final url = Uri.parse('$baseUrl/groups/$groupId/photos');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> imageList = json.decode(response.body);
      return imageList.map((json) => GroupImage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<void> addGroupImages(
      String token, int groupId, int userId, List<XFile> images) async {
    var uri = Uri.parse('$baseUrl/groups/albums');

    var request = http.MultipartRequest('POST', uri)
      ..fields['group_id'] = groupId.toString()
      ..fields['user_id'] = userId.toString()
      ..headers['Authorization'] = 'Bearer $token';

    for (var image in images) {
      File imageFile = File(image.path);

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
    } else {

      var responseBody = await response.stream.bytesToString();
      throw Exception('Failed to upload images');
    }
  }

  Future<void> deleteGroupImage(String token, int imageId) async {
    final url = Uri.parse('$baseUrl/albums/$imageId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }

  Future<http.Response> deleteUserGroup(
      String token, int groupId, int userId) async {
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
