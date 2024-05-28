class User {
  String email;
  String password;
  String role;
  String token;
  bool isVerified;

  User(
      {required this.email,
      required this.password,
      required this.role,
      required this.token,
      required this.isVerified});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'role': role,
        'token': token,
        'isVerified': isVerified,
      };
}
