import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/review.dart';

class ApiService {
  static String baseUrl = dotenv.env['BASE_URL']!;

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

  Future<String?> login(String email, String password,
      {bool isGoogle = false}) async {
    try {
      // Envoyer la requête POST
      print(jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'isGoogle': isGoogle.toString()
      }));

      print('$baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'isGoogle': isGoogle.toString()
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

  // add a POST request for create-hike
  Future<http.Response> createHike(
      String name,
      String description,
      int organizerId,
      String difficulty,
      String duration,
      File? image,
      File? gpxFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/hikes'));

    // Add headers
    request.headers['Content-Type'] = 'multipart/form-data';

    // Add fields (non-file data)
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['organizer_id'] = organizerId.toString();
    request.fields['difficulty'] = difficulty;
    request.fields['duration'] = duration;

    // Add image file if provided
    if (image != null) {
      var fileStream = http.ByteStream(image.openRead());
      var length = await image.length();

      // Create multipart file for image
      var multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: image.path.split('/').last, // File name
        contentType:
            MediaType('application', 'octet-stream'), // File content type
      );

      // Add image file to request
      request.files.add(multipartFile);
    }

    // Add GPX file if provided
    if (gpxFile != null) {
      var fileStream = http.ByteStream(gpxFile.openRead());
      var length = await gpxFile.length();

      // Create multipart file for GPX file
      var multipartFile = http.MultipartFile(
        'gpx_file',
        fileStream,
        length,
        filename: gpxFile.path.split('/').last, // File name
        contentType:
            MediaType('application', 'octet-stream'), // File content type
      );

      // Add GPX file to request
      request.files.add(multipartFile);
    }

    // Send the request
    var streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> createReview(Review review) {
    return http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(review.toJson()),
    );
  }

  Future<http.Response> updateReview(Review review) {
    return http.put(
      Uri.parse('$baseUrl/reviews/${review.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(review.toJson()),
    );
  }

  Future<http.Response> getReviewsByHike(int hikeId) {
    return http.get(Uri.parse('$baseUrl/reviews/hike/$hikeId'));
  }

  Future<http.Response> getReviewByUser(int userId, int hikeId) {
    return http.get(Uri.parse('$baseUrl/reviews/user/$userId/hike/$hikeId'));
  }

  // POST to subscribe to a hike
  Future<http.Response> subscribeToHike(int hikeId, int userId, String token) {
    print('token: $token' 'userId: $userId' 'hikeId: $hikeId');
    return http.post(
      Uri.parse('$baseUrl/hikes/subscribe'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'hike_id': hikeId,
        'user_id': userId,
      }),
    );
  }
}
