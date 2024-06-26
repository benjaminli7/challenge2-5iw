import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/models/hike.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<http.Response> signup(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }

  Future<String?> login(String email, String password) async {
    try {
      // Envoyer la requête POST
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      // Vérifier si la requête a réussi
      if (response.statusCode == 200) {
        // Décoder la réponse JSON
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response: $responseData');
        // Extraire le token (supposons qu'il est sous la clé 'token')
        final String? token = responseData['message'];

        print('Token: $token'); // Afficher le token pour déboguer

        return token;
      } else {
        // En cas d'erreur de la requête
        print('Failed to login. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // En cas d'exception lors de la requête
      print('Error occurred: $e');
      return null;
    }
  }

  Future<http.Response> getHikes() {
    return http.get(Uri.parse('$baseUrl/hikes'));
  }


}



