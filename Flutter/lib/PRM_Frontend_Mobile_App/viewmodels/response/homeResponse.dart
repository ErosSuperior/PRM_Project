import 'pagination_response.dart';

class ServiceCategoryDto {
  final int categoryId;
  final String categoryName;
  final String? description;
  final String? imageUrl;

  ServiceCategoryDto({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.imageUrl,
  });

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryDto(
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      categoryName: json['categoryName'] ?? json['CategoryName'] ?? '',
      description: json['description'] ?? json['Description'],
      imageUrl: json['imageUrl'] ?? json['ImageUrl'],
    );
  }
}

class BookingSummary {
  final int bookingId;
  final String? bookingCode;
  final DateTime bookingDate;
  final String? startTime;
  final String? customerName;
  final String? packageName;
  final String? status;
  final double? price;

  BookingSummary({
    required this.bookingId,
    this.bookingCode,
    required this.bookingDate,
    this.startTime,
    this.customerName,
    this.packageName,
    this.status,
    this.price,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      bookingId: json['bookingId'] ?? json['BookingId'] ?? 0,
      bookingCode: json['bookingCode'] ?? json['BookingCode'],
      bookingDate: DateTime.parse(json['bookingDate'] ?? json['BookingDate'] ?? DateTime.now().toIso8601String()),
      startTime: json['startTime'] ?? json['StartTime'],
      customerName: json['customerName'] ?? json['CustomerName'],
      packageName: json['packageName'] ?? json['PackageName'],
      status: json['status'] ?? json['Status'],
      price: (json['price'] ?? json['Price'] ?? 0.0).toDouble(),
    );
  }
}

class CustomerHomeResponse {
  final String name;
  final String? avatar;
  final PaginationResponse<ServiceCategoryDto> categories;

  CustomerHomeResponse({
    required this.name,
    this.avatar,
    required this.categories,
  });

  factory CustomerHomeResponse.fromJson(Map<String, dynamic> json) {
    final categoriesData = json['categories'] ?? json['Categories'];
    
    return CustomerHomeResponse(
      name: json['name'] ?? json['Name'] ?? '',
      avatar: json['avatar'] ?? json['Avatar'],
      categories: categoriesData != null 
          ? PaginationResponse.fromJson(
              categoriesData,
              (item) => ServiceCategoryDto.fromJson(item),
            )
          : PaginationResponse(items: [], totalItems: 0, totalPages: 0, currentPage: 1, pageSize: 10),
    );
  }
}

class AdminHomeResponse {
  final String name;
  final String? avatar;
  final int totalUsers;
  final int totalBookings;
  final int pendingBookings;
  final double totalRevenue;
  final List<BookingSummary> recentBookings;

  AdminHomeResponse({
    required this.name,
    this.avatar,
    required this.totalUsers,
    required this.totalBookings,
    required this.pendingBookings,
    required this.totalRevenue,
    required this.recentBookings,
  });

  factory AdminHomeResponse.fromJson(Map<String, dynamic> json) {
    var recentJson = json['recentBookings'] ?? json['RecentBookings'];
    List<BookingSummary> recentList = [];
    if (recentJson is List) {
      recentList = recentJson.map((item) => BookingSummary.fromJson(item)).toList();
    }

    return AdminHomeResponse(
      name: json['name'] ?? json['Name'] ?? '',
      avatar: json['avatar'] ?? json['Avatar'],
      totalUsers: json['totalUsers'] ?? json['TotalUsers'] ?? 0,
      totalBookings: json['totalBookings'] ?? json['TotalBookings'] ?? 0,
      pendingBookings: json['pendingBookings'] ?? json['PendingBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? json['TotalRevenue'] ?? 0.0).toDouble(),
      recentBookings: recentList,
    );
  }
}

class WorkerHomeResponse {
  final String name;
  final String? avatar;
  final int experienceYears;
  final bool isAvailable;
  final double averageRating;
  final int totalReviews;
  final List<BookingSummary> upcomingBookings;

  WorkerHomeResponse({
    required this.name,
    this.avatar,
    required this.experienceYears,
    required this.isAvailable,
    required this.averageRating,
    required this.totalReviews,
    required this.upcomingBookings,
  });

  factory WorkerHomeResponse.fromJson(Map<String, dynamic> json) {
    var upcomingJson = json['upcomingBookings'] ?? json['UpcomingBookings'];
    List<BookingSummary> upcomingList = [];
    if (upcomingJson is List) {
      upcomingList = upcomingJson.map((item) => BookingSummary.fromJson(item)).toList();
    }

    return WorkerHomeResponse(
      name: json['name'] ?? json['Name'] ?? '',
      avatar: json['avatar'] ?? json['Avatar'],
      experienceYears: json['experienceYears'] ?? json['ExperienceYears'] ?? 0,
      isAvailable: json['isAvailable'] ?? json['IsAvailable'] ?? false,
      averageRating: (json['averageRating'] ?? json['AverageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? json['TotalReviews'] ?? 0,
      upcomingBookings: upcomingList,
    );
  }
}
