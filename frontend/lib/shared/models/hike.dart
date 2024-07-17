import 'package:frontend/shared/models/subscriptions.dart';

class Hike {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final int duration;
  final bool isApproved;
  final String image;
  final String gpxFile;
  final List<Subscriptions> subscriptions;
  final double averageRating;


  Hike({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.isApproved,
    required this.image,
    required this.gpxFile,
    required this.subscriptions,
    required this.averageRating,
  });

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        difficulty: json['difficulty'],
        duration: json['duration'],
        isApproved: json['is_approved'],
        image: json['image'],
        gpxFile: json['gpx_file'],
        subscriptions: json['subscriptions'] != null
            ? List<Subscriptions>.from(json['subscriptions']
                .map((user) => Subscriptions.fromJson(user)))
            : [],
        averageRating: (json['average_rating'] is int)
            ? (json['average_rating'] as int).toDouble()
            : (json['average_rating'] ?? 0.0));
  }
}
