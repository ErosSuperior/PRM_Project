class Booking {
  final String id;
  final String serviceName;
  final String category;
  final DateTime dateTime;
  final String address;
  final String notes;
  final String status; // pending, confirmed, completed, cancelled
  double? rating; // null means not rated yet
  final DateTime createdAt;
  
  // Backend API fields
  final int? bookingId;
  final int? customerId;
  final int? workerId;
  final int? packageId;

  Booking({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.dateTime,
    required this.address,
    this.notes = '',
    this.status = 'pending',
    this.rating,
    DateTime? createdAt,
    this.bookingId,
    this.customerId,
    this.workerId,
    this.packageId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'address': address,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      serviceName: map['serviceName'] as String,
      category: map['category'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      address: map['address'] as String,
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Booking copyWith({
    String? id,
    String? serviceName,
    String? category,
    DateTime? dateTime,
    String? address,
    String? notes,
    String? status,
    double? rating,
    DateTime? createdAt,
    int? bookingId,
    int? customerId,
    int? workerId,
    int? packageId,
  }) {
    return Booking(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      workerId: workerId ?? this.workerId,
      packageId: packageId ?? this.packageId,
    );
  }
}

