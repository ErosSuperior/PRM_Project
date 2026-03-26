class BookingResponse {
  final int bookingId;
  final String? bookingCode;
  final int customerId;
  final String? customerName;
  final int? workerId;
  final String? workerName;
  final int packageId;
  final String? packageName;
  final String bookingDate;
  final String startTime;
  final String? endTime;
  final String address;
  final String? note;
  final double? totalPrice;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  BookingResponse({
    required this.bookingId,
    this.bookingCode,
    required this.customerId,
    this.customerName,
    this.workerId,
    this.workerName,
    required this.packageId,
    this.packageName,
    required this.bookingDate,
    required this.startTime,
    this.endTime,
    required this.address,
    this.note,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingId: json['bookingId'] ?? json['BookingId'] ?? 0,
      bookingCode: json['bookingCode'] ?? json['BookingCode'],
      customerId: json['customerId'] ?? json['CustomerId'] ?? 0,
      customerName: json['customerName'] ?? json['CustomerName'],
      workerId: json['workerId'] ?? json['WorkerId'],
      workerName: json['workerName'] ?? json['WorkerName'],
      packageId: json['packageId'] ?? json['PackageId'] ?? 0,
      packageName: json['packageName'] ?? json['PackageName'],
      bookingDate: json['bookingDate'] ?? json['BookingDate'] ?? '',
      startTime: json['startTime'] ?? json['StartTime'] ?? '',
      endTime: json['endTime'] ?? json['EndTime'],
      address: json['address'] ?? json['Address'] ?? '',
      note: json['note'] ?? json['Note'],
      totalPrice: json['totalPrice'] != null 
          ? (json['totalPrice'] as num).toDouble() 
          : (json['TotalPrice'] != null ? (json['TotalPrice'] as num).toDouble() : null),
      status: json['status'] ?? json['Status'],
      createdAt: json['createdAt'] ?? json['CreatedAt'],
      updatedAt: json['updatedAt'] ?? json['UpdatedAt'],
    );
  }
}
