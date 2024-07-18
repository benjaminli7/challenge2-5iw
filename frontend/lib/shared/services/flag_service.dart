import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config_service.dart';

class FlagService {
  String baseUrl = ConfigService.baseUrl;

  Future<http.Response> getFlags() {
    return http.get(Uri.parse('$baseUrl/flags'));
  }

  Future<bool> isFlagEnabled(String flag) async {
    final response = await getFlags();
    final json = jsonDecode(response.body);
    for (var item in json) {
      if (item['FeatureName'] == flag) {
        return item['Enabled'];
      }
    }
    return false;
  }
}
