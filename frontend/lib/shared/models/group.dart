class Group {
  final int id;
  final int organizerId;
  final List<int> members = [];
  final String startDate;
  final int hikeId;

  Group(
      {required this.id,
      required this.organizerId,
      required this.startDate,
      required this.hikeId});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      organizerId: json['organizer_id'],
      startDate: json['start_date'],
      hikeId: json['hike_id'],
    );
  }
}
