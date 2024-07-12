class Hike {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final String duration;
  final bool isApproved;
  final String image;
  final String gpxFile;

  Hike(
      {required this.id,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.duration,
      required this.isApproved,
      required this.image,
      required this.gpxFile});
  static Hike defaultHike() {
    return Hike(id: 0, name: 'Default Hike', description: '', difficulty: '', duration: '', isApproved: false, image: '', gpxFile: '');
  }
  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        difficulty: json['difficulty'],
        duration: json['duration'],
        isApproved: json['is_approved'],
        image: json['image'],
        gpxFile: json['gpx_file']);
  }
}
