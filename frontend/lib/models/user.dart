class User {
  int id;
  String email;
  String password;
  String role;
  String token;
  bool isVerified;

  User(
      {required this.id,
        required this.email,
      required this.password,
      required this.role,
      required this.token,
      required this.isVerified});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'role': role,
        'token': token,
        'isVerified': isVerified,
      };
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      token: json['token'],
      isVerified: json['verified'] ?? false,
    );
  }
}
