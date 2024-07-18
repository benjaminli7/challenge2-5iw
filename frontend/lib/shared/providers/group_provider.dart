import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupProvider with ChangeNotifier {
  DateTime? hikeDate;
  String groupName = '';
  String groupDescription = '';
  int maxUsers = 0;

  Map<String, dynamic> collectGroupData() {
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    return {
      'name': groupName,
      'description': groupDescription,
      'hikeDate': hikeDate != null ? formatter.format(hikeDate!) : null,
      'maxUsers': maxUsers
    };
  }

  void selectDate(DateTime date) {
    hikeDate = date;
    notifyListeners();
  }

  void setGroupName(String name) {
    groupName = name;
    notifyListeners();
  }

  void setMaxUsers(int maxParticipants) {
    maxUsers = maxParticipants;
    notifyListeners();
  }

  void setGroupDescription(String description) {
    groupDescription = description;
    notifyListeners();
  }
}
