class Settings {
  bool weatherAPI;
  bool googleAPI;

  Settings({required this.weatherAPI, required this.googleAPI});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      weatherAPI: json['weather_api'],
      googleAPI: json['google_api'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather_api': weatherAPI,
      'google_api': googleAPI,
    };
  }
}
