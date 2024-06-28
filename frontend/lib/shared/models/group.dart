import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';
class Group {
  final int id;
  final User organizator;
  final List<User> members = [];
  final DateTime dateStart ;
  final Hike hike;


  Group({required this.id, required this.organizator, required this.dateStart, required this.hike});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      organizator: json['organizator'],
      dateStart: json['dateStart'],
      hike: json['hike'],

    );
  }
}
