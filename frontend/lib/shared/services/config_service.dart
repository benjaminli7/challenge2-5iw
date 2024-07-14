import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'API_KEY not found';
}
