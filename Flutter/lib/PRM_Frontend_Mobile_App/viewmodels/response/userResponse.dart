class WorkerProfileResponse {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final int experienceYears;
  final String bio;
  final bool isAvailable;
  final int totalReviews;
  final double averageRating;
  final String? avatar; // Added avatar field

  WorkerProfileResponse({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    required this.experienceYears,
    required this.bio,
    required this.isAvailable,
    required this.totalReviews,
    required this.averageRating,
    this.avatar,
  });

  factory WorkerProfileResponse.fromJson(Map<String, dynamic> json) {
    return WorkerProfileResponse(
      id: json['id'] ?? json['Id'],
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      phone: json['phone'] ?? json['Phone'],
      address: json['address'] ?? json['Address'],
      experienceYears: json['experienceYears'] ?? json['ExperienceYears'] ?? 0,
      bio: json['bio'] ?? json['Bio'] ?? '',
      isAvailable: json['isAvailable'] ?? json['IsAvailable'] ?? false,
      totalReviews: json['TotalReviews'] ?? json['totalReviews'] ?? 0,
      averageRating: (json['AverageRating'] ?? json['averageRating'] ?? 0).toDouble(),
      avatar: json['avatar'] ?? json['Avatar'], // Map avatar from JSON
    );
  }
}
class UserProfileResponse {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? avatar;
  final bool? isActive;

  UserProfileResponse({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.avatar,
    this.isActive,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'] ?? json['Id'],
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      phone: json['phone'] ?? json['Phone'],
      address: json['address'] ?? json['Address'],
      avatar: json['avatar'] ?? json['Avatar'],
      isActive: json['isActive'] ?? json['IsActive'],
    );
  }
}