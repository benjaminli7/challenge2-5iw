class Subscriptions {
  final int hikeId;
  final int userId;

  Subscriptions({
    required this.hikeId,
    required this.userId,
  });

  factory Subscriptions.fromJson(Map<String, dynamic> json) {
    return Subscriptions(
      hikeId: json['hike_id'],
      userId: json['user_id'],
    );
  }
}
