class User {
  int id;
  String email;
  String? username;
  String password;
  String role;
  String token;
  bool isVerified;

  User({
    required this.id,
    required this.email,
    this.username,
    required this.password,
    required this.role,
    required this.token,
    required this.isVerified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'password': password,
    'role': role,
    'token': token,
    'isVerified': isVerified,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'],
      password: json['password'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'] ?? '',
      isVerified: json['verified'] ?? false,
    );
  }
}
