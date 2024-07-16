class User {
  int id;
  String email;
  String? username;
  String password;
  String role;
  String token;
  bool isVerified;
  String? profileImage;

  User(
      {required this.id,
      required this.email,
      required this.password,
      required this.role,
      required this.username,
      required this.token,
      this.profileImage,
      required this.isVerified});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'username': username,
        'role': role,
        'token': token,
        'isVerified': isVerified,
        'profile_image': profileImage,
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
      profileImage: json['profile_image'],
    );
  }
}
