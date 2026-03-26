class PaginationResponse<T> {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final List<T> items;

  PaginationResponse({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.items,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Handle list parsing safely
    var itemsJson = json['items'] ?? json['Items'] ?? [];
    List<T> itemsList = [];
    if (itemsJson is List) {
      itemsList = itemsJson
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
    }

    return PaginationResponse<T>(
      totalItems: (json['totalItems'] ?? json['TotalItems'] ?? 0).toInt(),
      totalPages: (json['totalPages'] ?? json['TotalPages'] ?? 0).toInt(),
      currentPage: (json['currentPage'] ?? json['CurrentPage'] ?? 1).toInt(),
      pageSize: (json['pageSize'] ?? json['PageSize'] ?? 10).toInt(),
      items: itemsList,
    );
  }
}
