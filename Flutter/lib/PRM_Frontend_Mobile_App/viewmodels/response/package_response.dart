class PackageResponse {
  final int packageId;
  final int categoryId;
  final String packageName;
  final String? description;
  final double price;
  final int durationHours;
  final bool? isActive;

  PackageResponse({
    required this.packageId,
    required this.categoryId,
    required this.packageName,
    this.description,
    required this.price,
    required this.durationHours,
    this.isActive,
  });

  factory PackageResponse.fromJson(Map<String, dynamic> json) {
    return PackageResponse(
      packageId: json['packageId'] ?? json['PackageId'] ?? 0,
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      packageName: json['packageName'] ?? json['PackageName'] ?? '',
      description: json['description'] ?? json['Description'],
      price: (json['price'] ?? json['Price'] ?? 0).toDouble(),
      durationHours: json['durationHours'] ?? json['DurationHours'] ?? 0,
      isActive: json['isActive'] ?? json['IsActive'],
    );
  }
}
