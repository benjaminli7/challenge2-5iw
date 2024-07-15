class Settings {
  bool weatherAPI;
  bool googleAuth;
  Settings({required this.weatherAPI, required this.googleAuth});

  factory(Map<String, dynamic> json) {
    return Settings(
      weatherAPI: json['weatherAPI'] ?? true,
      googleAuth: json['googleAuth'] ?? true,
    );
  }
}
