class Hike {
  int id;
  String name;
  String description;
  String image;
  String location;
  int difficulty;
  DateTime startDate;
  DateTime endDate;
  int organizerId;

  Hike({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.location,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.organizerId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'location': location,
        'difficulty': difficulty,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'organizer_id': organizerId,
      };

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      location: json['location'],
      difficulty: json['difficulty'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      organizerId: json['organizer_id'],
    );
  }
}
