class WatchedBookModel {
  final String watchedId;
  final String userId;
  final String bookId;
  final String watchedAt;
  final String status;

  const WatchedBookModel({
    required this.watchedId,
    required this.userId,
    required this.bookId,
    required this.watchedAt,
    required this.status,
  });

  factory WatchedBookModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return WatchedBookModel(
      watchedId: s(json['watched_id']),
      userId: s(json['user_id']),
      bookId: s(json['book_id']),
      watchedAt: s(json['watched_at']),
      status: s(json['status']),
    );
  }
}
