import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/shared/services/group_service.dart';

class GroupProvider with ChangeNotifier {
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


}
