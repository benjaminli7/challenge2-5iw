class GroupImage {
  final int id;
  final int groupId;
  final int userId;
  final String path;
  final DateTime createdAt;

  GroupImage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.path,
    required this.createdAt,
  });

  factory GroupImage.fromJson(Map<String, dynamic> json) {
    return GroupImage(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      path: json['path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'path': path,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
