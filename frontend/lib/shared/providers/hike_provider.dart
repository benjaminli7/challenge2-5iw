import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart' as xml;

import '../models/review.dart';

class HikeProvider with ChangeNotifier {
  List<Hike> _hikes = [];

  List<Hike> get hikes => _hikes;

  Future<void> fetchHikes() async {
    try {
      final response = await ApiService().getHikes();
      print('fetchHikes response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _hikes = data.map((json) => Hike.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch hikes: $e');
    }
  }

  // Future<void> fetchHike(int id) async {
  //   try {
  //     final response = await ApiService().getHike(id);
  //     print('fetchHike response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final hike = Hike.fromJson(data);
  //       _hikes.add(hike);
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print('Failed to fetch hike: $e');
  //   }
  // }

  Future<void> createHike(String name, String description, int organizerId,
      String difficulty, int duration, File image, File gpxFile) async {
    try {
      final response = await ApiService().createHike(
          name, description, organizerId, difficulty, duration, image, gpxFile);
      if (response.statusCode == 200) {
        print('Hike created successfully');
      } else {
        print('Failed to create hike: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create hike: $e');
    }
  }

  //create a function to parse the gpx file
  Future<List<LatLng>> parseGPX(String file) async {
    try {
      final document = xml.XmlDocument.parse(file);
      final routePoint = <LatLng>[];

      // <trkseg>
      // 			<trkpt lat="48.013010" lon="7.073140">
      final trkptElements = document.findAllElements('trkpt');
      final rtepElements = document.findAllElements('rtept');

      if (trkptElements.isEmpty && rtepElements.isEmpty) {
        return [];
      }
      if (trkptElements.isNotEmpty) {
        print('trkptElements: $trkptElements');
        for (var element in trkptElements) {
          final lat = double.parse(element.getAttribute('lat') ?? '0');
          final lon = double.parse(element.getAttribute('lon') ?? '0');
          routePoint.add(LatLng(lat, lon));
        }
      }
      if (rtepElements.isNotEmpty) {
        print('rtepElements: $rtepElements');
        for (var element in rtepElements) {
          final lat = double.parse(element.getAttribute('lat') ?? '0');
          final lon = double.parse(element.getAttribute('lon') ?? '0');
          routePoint.add(LatLng(lat, lon));
        }
      }
      return routePoint;
    } catch (e) {
      print('Error loading GPX file: $e');
      return [];
    }
  }

  Future<void> createReview(Review review) async {
    try {
      final response = await ApiService().createReview(review);
      if (response.statusCode == 200) {
        print('Review created successfully');
      } else {
        print('Failed to create review_widget.dart: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create review_widget.dart: $e');
    }
  }

  Future<void> updateReview(Review review) async {
    try {
      final response = await ApiService().updateReview(review);
      if (response.statusCode == 200) {
        await fetchHikes();
        print('Review updated successfully');
      } else {
        print('Failed to update review_widget.dart: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update review_widget.dart: $e');
    }
  }

  Future<List<Review>> fetchReviewsByHike(int hikeId) async {
    try {
      final response = await ApiService().getReviewsByHike(hikeId);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Failed to fetch reviews: $e');
      return [];
    }
  }

  Future<Review?> fetchReviewByUser(int userId, int hikeId) async {
    try {
      final response = await ApiService().getReviewByUser(userId, hikeId);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Review.fromJson(data);
      } else {
        print('Failed to fetch review: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Failed to fetch review: $e');
      return null;
    }
  }

  Future<void> userSubscribeToHike(int hikeId, int userId, String token) async {
    try {
      final response = await ApiService().subscribeToHike(hikeId, userId, token);
      if (response.statusCode == 200) {
        print('User subscribed to hike successfully');
      } else {
        print('Failed to subscribe to hike: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to subscribe to hike: $e');
    }
  }
}
