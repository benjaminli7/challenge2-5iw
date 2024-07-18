class Message {
  final int userId;
  // final int groupId;
  final String content;
  final String? username;
  final DateTime? createdAt;

  // Message({required this.userId, required this.groupId, required this.content});
  Message({required this.userId, required this.content, this.username, this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      username: json['User']['username'],
      userId: json['UserID'],
      // groupId: json['groupId'],
      content: json['Content'],
      createdAt: DateTime.parse(json['CreatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      // 'groupId': groupId,
      'content': content,
      'username': username,
      'createdAt': createdAt
    };
  }
}
