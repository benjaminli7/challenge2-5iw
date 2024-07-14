import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'API_KEY not found';
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'WS_URL not found';
}
