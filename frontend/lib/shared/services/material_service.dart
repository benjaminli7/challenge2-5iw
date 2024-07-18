import 'dart:convert';

import 'package:frontend/shared/models/material.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:http/http.dart' as http;

class MaterialService {
  String baseUrl = ConfigService.baseUrl;

  Future<void> addMaterials(
      String token, String groupId, List<String> materials) async {
    final url = '$baseUrl/groups/$groupId/materials';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'materials': materials,
      }),
    );


  }

  Future<List<Materiel>> getMaterialsByGroupId(
      String token, int groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/materials'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> materialsJson = jsonDecode(response.body);
      return materialsJson.map((json) => Materiel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch materials');
    }
  }

  Future<void> addBringer(String token, int materialId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/materials/$materialId/bring/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add bringer');
    }
  }

  Future<void> removeBringer(String token, int materialId, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/materials/$materialId/bring/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove bringer');
    }
  }
}
