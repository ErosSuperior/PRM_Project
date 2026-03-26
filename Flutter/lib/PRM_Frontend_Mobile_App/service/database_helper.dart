import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking.dart';
import '../models/rating.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        serviceName TEXT NOT NULL,
        category TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        address TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        createdAt TEXT NOT NULL
      )
    ''');

    // Create ratings table
    await db.execute('''
      CREATE TABLE ratings (
        id TEXT PRIMARY KEY,
        bookingId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookingId) REFERENCES bookings(id) ON DELETE CASCADE
      )
    ''');
  }

  // Booking CRUD operations
  Future<String> insertBooking(Booking booking) async {
    final db = await database;
    await db.insert(
      'bookings',
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return booking.id;
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      orderBy: 'dateTime DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<Booking?> getBooking(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Booking.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await database;
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(String id) async {
    final db = await database;
    // Delete associated ratings first
    await db.delete('ratings', where: 'bookingId = ?', whereArgs: [id]);
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // Rating CRUD operations
  Future<String> insertRating(Rating rating) async {
    final db = await database;
    await db.insert(
      'ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Update booking with rating
    final booking = await getBooking(rating.bookingId);
    if (booking != null) {
      final updatedBooking = Booking(
        id: booking.id,
        serviceName: booking.serviceName,
        category: booking.category,
        dateTime: booking.dateTime,
        address: booking.address,
        notes: booking.notes,
        status: booking.status,
        rating: rating.rating.toDouble(),
        createdAt: booking.createdAt,
      );
      await updateBooking(updatedBooking);
    }
    return rating.id;
  }

  Future<Rating?> getRatingByBookingId(String bookingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ratings',
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );

    if (maps.isNotEmpty) {
      return Rating.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Rating>> getAllRatings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ratings',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Rating.fromMap(maps[i]);
    });
  }

  Future<int> updateRating(Rating rating) async {
    final db = await database;
    final result = await db.update(
      'ratings',
      rating.toMap(),
      where: 'id = ?',
      whereArgs: [rating.id],
    );
    // Update booking with new rating
    final booking = await getBooking(rating.bookingId);
    if (booking != null) {
      final updatedBooking = Booking(
        id: booking.id,
        serviceName: booking.serviceName,
        category: booking.category,
        dateTime: booking.dateTime,
        address: booking.address,
        notes: booking.notes,
        status: booking.status,
        rating: rating.rating.toDouble(),
        createdAt: booking.createdAt,
      );
      await updateBooking(updatedBooking);
    }
    return result;
  }

  Future<int> deleteRating(String id) async {
    final db = await database;
    return await db.delete('ratings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
