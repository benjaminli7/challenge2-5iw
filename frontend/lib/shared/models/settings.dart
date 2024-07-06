class Settings {
  bool weatherAPI;

  Settings({required this.weatherAPI});

  factory(Map<String, dynamic> json) {
    return Settings(
      weatherAPI: json['weatherAPI'] ?? true,
    );
  }
}
