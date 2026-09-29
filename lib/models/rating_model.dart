class RatingModel {
  final String ratingId;
  final String userId;
  final String bookId;
  final String rating;
  final String createdAt;
  final String status;

  const RatingModel({
    required this.ratingId,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.createdAt,
    required this.status,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic value) => value?.toString() ?? '';

    return RatingModel(
      ratingId: s(json['rating_id'] ?? json['id']),
      userId: s(json['user_id']),
      bookId: s(json['book_id']),
      rating: s(json['rating']),
      createdAt: s(json['created_at']),
      status: s(json['status']),
    );
  }
}
