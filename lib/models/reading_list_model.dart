class ReadingListModel {
  final String listId;
  final String userId;
  final String bookId;
  final String savedAt;
  final String status;

  ReadingListModel({
    required this.listId,
    required this.userId,
    required this.bookId,
    required this.savedAt,
    required this.status,
  });

  factory ReadingListModel.fromJson(Map<String, dynamic> json) {
    return ReadingListModel(
      listId: json['list_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      savedAt: json['saved_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}