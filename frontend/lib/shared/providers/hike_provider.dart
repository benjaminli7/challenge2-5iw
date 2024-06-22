import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:frontend/shared/models/hike.dart';

class HikeProvider with ChangeNotifier {
  List<Hike> _hikes = [];

  List<Hike> get hikes => _hikes;

  Future<void> fetchHikes() async {
    try {
      final response = await ApiService().getHikes();
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _hikes = data.map((json) => Hike.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch hikes: $e');
    }
  }
}
