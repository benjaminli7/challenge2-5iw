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
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _hikes = data.map((json) => Hike.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch hikes: $e');
    }
  }


  Future<void> createHike(String name, String description, int organizerId,  String difficulty, int duration, File image, File gpxFile, String lat, String lng, String token
      ) async {
    try {
      final response = await ApiService().createHike(
          name, description, organizerId, difficulty, duration, image, gpxFile , lat, lng, token);

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
        for (var element in trkptElements) {
          final lat = double.parse(element.getAttribute('lat') ?? '0');
          final lon = double.parse(element.getAttribute('lon') ?? '0');
          routePoint.add(LatLng(lat, lon));
        }
      }
      if (rtepElements.isNotEmpty) {
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

  Future<void> createReview(Review review, String token) async {
    try {
      final response = await ApiService().createReview(review, token);
      if (response.statusCode == 200) {
        await fetchReviewsByHike(review.hikeId);

      }
    } catch (e) {
      print('Failed to create review_widget.dart: $e');
    }
  }

  Future<void> updateReview(Review review, String token) async {
    try {
      final response = await ApiService().updateReview(review, token);
      if (response.statusCode == 200) {
        await fetchHikes();
        await fetchReviewsByHike(review.hikeId);

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
        return [];
      }
    } catch (e) {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> userSubscribeToHike(int hikeId, int userId, String token) async {
    try {
      final response = await ApiService().subscribeToHike(hikeId, userId, token);

    } catch (e) {
      print('Failed to subscribe to hike: $e');
    }
  }
}
