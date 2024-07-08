class Review {
  final int id;
  final int userId;
  final int hikeId;
  final int rating;
  final String comment;

  Review({
    required this.id,
    required this.userId,
    required this.hikeId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      hikeId: json['hike_id'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hike_id': hikeId,
      'rating': rating,
      'comment': comment,
    };
  }
}
