class CreateRatingRequest {
  final int bookingId;
  final int customerId;
  final int workerId;
  final int ratingScore;
  final String? comment;

  CreateRatingRequest({
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.ratingScore,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'customerId': customerId,
        'workerId': workerId,
        'ratingScore': ratingScore,
        if (comment != null) 'comment': comment,
      };
}

class UpdateRatingRequest {
  final int? ratingScore;
  final String? comment;

  UpdateRatingRequest({
    this.ratingScore,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ratingScore != null) map['ratingScore'] = ratingScore;
    if (comment != null) map['comment'] = comment;
    return map;
  }
}
