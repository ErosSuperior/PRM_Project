class CategoryResponse {
  final int categoryId;
  final String categoryName;
  final String? description;

  CategoryResponse({
    required this.categoryId,
    required this.categoryName,
    this.description,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      categoryName: json['gategoryName'] ?? json['GategoryName'] ?? json['categoryName'] ?? json['CategoryName'] ?? '',
      description: json['description'] ?? json['Description'],
    );
  }
}
