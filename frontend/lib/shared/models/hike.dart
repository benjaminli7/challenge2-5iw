class Hike {
  final int id;
  final String name;
  final String description;

  Hike({required this.id, required this.name, required this.description});

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
