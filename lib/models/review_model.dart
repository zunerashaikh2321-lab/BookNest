class ReviewModel {
  final String reviewId;
  final String userId;
  final String bookId;
  final String rating;
  final String reviewText;
  final String createdAt;
  final String status;

  const ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    required this.status,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return ReviewModel(
      reviewId: s(json['review_id']),
      userId: s(json['user_id']),
      bookId: s(json['book_id']),
      rating: s(json['rating']),
      reviewText: s(json['review_text']),
      createdAt: s(json['created_at']),
      status: s(json['status']),
    );
  }
}
