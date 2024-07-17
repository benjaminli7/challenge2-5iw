import "package:frontend/shared/models/user.dart";

class Materiel {
  final int id;
  final String name;
  final List<User> users;

  Materiel({
    required this.id,
    required this.name,
    required this.users,
  });

  factory Materiel.fromJson(Map<String, dynamic> json) {
    var usersJson = json['Users'] as List;
    List<User> usersList =
        usersJson.map((i) => User.fromJson(i)).toList();

    return Materiel(
      id: json['ID'],
      name: json['Name'],
      users: usersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}
