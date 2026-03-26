class RatingResponse {
  final int ratingId;
  final int bookingId;
  final int customerId;
  final int workerId;
  final int? ratingScore;
  final String? comment;
  final String? createdAt;

  RatingResponse({
    required this.ratingId,
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    this.ratingScore,
    this.comment,
    this.createdAt,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      ratingId: json['ratingId'] as int,
      bookingId: json['bookingId'] as int,
      customerId: json['customerId'] as int,
      workerId: json['workerId'] as int,
      ratingScore: json['ratingScore'] as int?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
