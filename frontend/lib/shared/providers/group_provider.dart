import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:intl/intl.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  List<Group> get groups => _groups;
  DateTime? hikeDate;

  Map<String, dynamic> collectGroupData() {
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    return {
      'hikeDate': hikeDate != null ? formatter.format(hikeDate!) : null,
    };
  }

  void selectDate(DateTime date) {
    hikeDate = date;
    notifyListeners();
  }

  Future<void> fetchGroups() async {
    try {
      final response = await ApiService().getGroups();
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _groups = data.map((json) => Group.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch groups: $e');
    }
  }
}
