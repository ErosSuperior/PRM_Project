import 'dart:convert';
import 'package:http/http.dart' as http;

import '../configuration/appsetting.dart';
import '../viewmodels/request/paginationRequest.dart';
import '../viewmodels/response/pagination_response.dart';
import '../viewmodels/response/userResponse.dart';
// Import your models here

class WorkerService {
  // Now returns PaginationResponse<WorkerProfileResponse>
  Future<PaginationResponse<WorkerProfileResponse>> getWorkerUsers(
      PaginationRequest request, String authToken) async {

    final baseUrl = AppSetting.apiUrl.endsWith('/')
        ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1)
        : AppSetting.apiUrl;

    final Map<String, String> queryParams = {
      'pageNumber': request.pageNumber.toString(),
      'pageSize': request.pageSize.toString(),
      'sortBy': request.sortBy,
      'sortOrder': request.sortOrder.toString(),
      'filterBy': request.filterBy,
    };

    if (request.searchTerm != null && request.searchTerm!.isNotEmpty) {
      queryParams['searchTerm'] = request.searchTerm!;
    }

    final url = Uri.parse('$baseUrl/user/UserManagement/list')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Server returned success but empty body.');
        }
        final Map<String, dynamic> data = jsonDecode(response.body);

        // This is the magic line. We pass the data AND the fromJson function
        return PaginationResponse<WorkerProfileResponse>.fromJson(
          data,
              (json) => WorkerProfileResponse.fromJson(json),
        );

      } else {
        String errorMessage = 'Failed to fetch workers (Status: ${response.statusCode})';
        // ... error handling logic ...
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}