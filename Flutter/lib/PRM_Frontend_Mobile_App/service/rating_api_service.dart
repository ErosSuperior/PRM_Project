import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/request/ratingRequest.dart';
import '../viewmodels/response/ratingResponse.dart';

class RatingApiService {
  final String baseUrl;

  RatingApiService({String? baseUrl})
      : baseUrl = baseUrl ?? AppSetting.apiUrl;

  String _getUrl(String endpoint) {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$url/api/rating/$endpoint';
  }

  Map<String, String> _getHeaders({String? accessToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // Get rating by booking ID
  Future<RatingResponse?> getRatingByBookingId(int bookingId, {String? accessToken}) async {
    try {
      final url = Uri.parse(_getUrl('booking/$bookingId'));
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return RatingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rating: $e');
    }
  }

  // Get all ratings for a customer
  Future<List<RatingResponse>> getRatingsByCustomerId(int customerId, {String? accessToken}) async {
    try {
      final url = Uri.parse(_getUrl('customer/$customerId'));
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RatingResponse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ratings: $e');
    }
  }

  // Create a new rating
  Future<RatingResponse> createRating(CreateRatingRequest request, {String? accessToken}) async {
    try {
      final url = Uri.parse(_getUrl(''));
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken: accessToken),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RatingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final errorMessage = errorBody?['message'] ?? 'Failed to create rating: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating rating: $e');
    }
  }

  // Update a rating
  Future<RatingResponse> updateRating(int ratingId, UpdateRatingRequest request, {String? accessToken}) async {
    try {
      final url = Uri.parse(_getUrl('$ratingId'));
      final response = await http.put(
        url,
        headers: _getHeaders(accessToken: accessToken),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return RatingResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final errorMessage = errorBody?['message'] ?? 'Failed to update rating: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error updating rating: $e');
    }
  }

  // Delete a rating
  Future<bool> deleteRating(int ratingId, {String? accessToken}) async {
    try {
      final url = Uri.parse(_getUrl('$ratingId'));
      final response = await http.delete(
        url,
        headers: _getHeaders(accessToken: accessToken),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting rating: $e');
    }
  }
}
