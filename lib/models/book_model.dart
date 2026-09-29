class BookModel {
  final String bookId;
  final String title;
  final String author;
  final String categoryId;
  final String description;
  final String imageUrl;
  final String price;
  final String rating;
  final String totalReviews;
  final String isFeatured;
  final String isBestSeller;
  final String status;
  final String createdAt;
  final String publishedDate;

  const BookModel({
    required this.bookId,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.totalReviews,
    required this.isFeatured,
    required this.isBestSeller,
    required this.status,
    required this.createdAt,
    required this.publishedDate,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return BookModel(
      bookId: s(json['book_id']),
      title: s(json['title']),
      author: s(json['author']),
      categoryId: s(json['category_id']),
      description: s(json['description']),
      imageUrl: s(json['image_url']),
      price: s(json['price']),
      rating: s(json['rating']),
      totalReviews: s(json['total_reviews']),
      isFeatured: s(json['is_featured']),
      isBestSeller: s(json['is_best_seller']),
      status: s(json['status']),
      createdAt: s(json['created_at']),
      publishedDate: s(json['published_date']),
    );
  }
}
