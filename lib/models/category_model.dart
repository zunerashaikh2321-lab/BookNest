class CategoryModel {
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final String status;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic value) => value?.toString() ?? '';

    return CategoryModel(
      categoryId: s(json['category_id'] ?? json['id']),
      name: s(json['name'] ?? json['category_name'] ?? json['title']),
      description: s(json['description']),
      imageUrl: s(json['image_url'] ?? json['image']),
      status: s(json['status']),
    );
  }
}
