class PaginationRequest {
  int pageNumber;
  int pageSize;
  String sortBy;
  int sortOrder; // 1 for ascending, -1 for descending
  String? searchTerm;
  String filterBy;

  PaginationRequest({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.sortBy = "default",
    this.sortOrder = 1,
    this.searchTerm,
    this.filterBy = "default",
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'filterBy': filterBy,
    };

    // Only add searchTerm to the JSON if it's not null
    if (searchTerm != null) {
      map['searchTerm'] = searchTerm;
    }

    return map;
  }
}