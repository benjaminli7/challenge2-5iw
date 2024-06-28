import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/services/api_service.dart';

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

  Future<void> createHike(String name, String description, int organizerId,
      String difficulty, String duration) async {
    try {
      final response = await ApiService()
          .createHike(name, description, organizerId, difficulty, duration);
      if (response.statusCode == 200) {
        print('Hike created successfully');
      } else {
        print('Failed to create hike: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create hike: $e');
    }
  }
}
