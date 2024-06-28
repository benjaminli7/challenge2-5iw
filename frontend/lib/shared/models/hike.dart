class Hike {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final String duration;
  final bool isApproved;

  Hike(
      {required this.id,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.duration,
      required this.isApproved});

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      duration: json['duration'],
      isApproved: json['is_approved'],
    );
  }
}
