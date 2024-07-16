import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/review.dart';
import '../models/user.dart';
import 'config_service.dart';

class ApiService {

  String baseUrl = ConfigService.baseUrl;

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? token = responseData['message'];
        return token;
      } else {
        print('Failed to login. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  Future<http.Response> getHikes() {
    return http.get(Uri.parse('$baseUrl/hikes'));
  }

  Future<http.Response> createHike(
      String name,
      String description,
      int organizerId,
      String difficulty,
      String duration,
      File? image,
      File? gpxFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/hikes'));

    request.headers['Content-Type'] = 'multipart/form-data';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['organizer_id'] = organizerId.toString();
    request.fields['difficulty'] = difficulty;
    request.fields['duration'] = duration;

    if (image != null) {
      var fileStream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: image.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(multipartFile);
    }

    if (gpxFile != null) {
      var fileStream = http.ByteStream(gpxFile.openRead());
      var length = await gpxFile.length();
      var multipartFile = http.MultipartFile(
        'gpx_file',
        fileStream,
        length,
        filename: gpxFile.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(multipartFile);
    }

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

  Future<http.Response> getHikesWithRatings() {
    return http.get(Uri.parse('$baseUrl/hikes/withRatings'));
  }

  Future<http.Response> getReviewsByHike(int hikeId) {
    return http.get(Uri.parse('$baseUrl/reviews/hike/$hikeId'));
  }

  Future<http.Response> getReviewByUser(int userId, int hikeId) {
    return http.get(Uri.parse('$baseUrl/reviews/user/$userId/hike/$hikeId'));
  }

  Future<http.Response> subscribeToHike(int hikeId, int userId, String token) {
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

  Future<User> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<http.Response> updateUserProfile(User user, String token) {
    return http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );
  }
}
