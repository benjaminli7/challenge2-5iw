class User {
  int id;
  String email;
  String password;
  String role;
  String token;
  String username;
  bool isVerified;

  User(
      {required this.id,
      required this.email,
      required this.password,
      required this.role,
      required this.username,
      required this.token,
      required this.isVerified});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'username': username,
        'role': role,
        'token': token,
        'isVerified': isVerified,
      };
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      username: json['username'],
      role: json['role'],
      token: json['token'],
      isVerified: json['verified'] ?? false,
    );
  }
}
