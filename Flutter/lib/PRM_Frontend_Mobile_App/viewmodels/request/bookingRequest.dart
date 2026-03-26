class CreateBookingRequest {
  final int customerId;
  final int? workerId;
  final String packageId;
  final String bookingDate; // Format: "YYYY-MM-DD"
  final String startTime; // Format: "HH:mm:ss"
  final String address;
  final String? note;
  final double? totalPrice;

  CreateBookingRequest({
    required this.customerId,
    required this.workerId,
    required this.packageId,
    required this.bookingDate,
    required this.startTime,
    required this.address,
    this.note,
    this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'workerId': workerId,
        'packageId': packageId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'address': address,
        if (note != null) 'note': note,
        if (totalPrice != null) 'totalPrice': totalPrice,
      };
}

class UpdateBookingRequest {
  final int? workerId;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final String? address;
  final String? note;
  final double? totalPrice;
  final String? status;

  UpdateBookingRequest({
    this.workerId,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.address,
    this.note,
    this.totalPrice,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (workerId != null) map['workerId'] = workerId;
    if (bookingDate != null) map['bookingDate'] = bookingDate;
    if (startTime != null) map['startTime'] = startTime;
    if (endTime != null) map['endTime'] = endTime;
    if (address != null) map['address'] = address;
    if (note != null) map['note'] = note;
    if (totalPrice != null) map['totalPrice'] = totalPrice;
    if (status != null) map['status'] = status;
    return map;
  }
}

class AssignWorkerRequest {
  final int workerId;

  AssignWorkerRequest({required this.workerId});

  Map<String, dynamic> toJson() => {
    'workerId': workerId,
  };
}
