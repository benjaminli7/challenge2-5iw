import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupProvider with ChangeNotifier {
  String? groupType;
  String? difficulty;
  DateTime? hikeDate;
  String? startTime;

  Map<String, dynamic> collectGroupData() {
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    return {
      'groupType': groupType,
      'difficulty': difficulty,
      'hikeDate': hikeDate != null ? formatter.format(hikeDate!) : null,
      'startTime': startTime,
    };
  }

  void selectGroupType(String type) {
    groupType = type;
    notifyListeners();
  }

  void selectDifficulty(String level) {
    difficulty = level;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    hikeDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    startTime = time;
    notifyListeners();
  }
}
