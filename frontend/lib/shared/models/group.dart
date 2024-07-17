import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/models/user.dart';

class Group {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;
  final DateTime startDate;
  final Hike hike;
  final User organizer;
  final String name;
  final int maxUsers;
  final List<User> users;

  Group({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
    required this.startDate,
    required this.hike,
    required this.organizer,
    required this.name,
    required this.maxUsers,
    required this.users,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      hike: Hike.fromJson(json['hike']),
      organizer: User.fromJson(json['organizer']),
      name: json['name'],
      maxUsers: json['max_users'],
      users:
          (json['Users'] as List).map((user) => User.fromJson(user)).toList(),
    );
  }
}
