import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/request/paginationRequest.dart';
import '../viewmodels/response/homeResponse.dart';

class HomeService {
  final String _baseUrl = AppSetting.apiUrl.endsWith('/') 
      ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1) 
      : AppSetting.apiUrl;

  Future<CustomerHomeResponse> getCustomerHome(String token, PaginationRequest pagination) async {
    final queryParams = 'pageNumber=${pagination.pageNumber}&pageSize=${pagination.pageSize}';
    final url = Uri.parse('$_baseUrl/home/Home/customer?$queryParams');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return CustomerHomeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load customer home: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Home Error: $e');
    }
  }

  Future<AdminHomeResponse> getAdminHome(String token) async {
    final url = Uri.parse('$_baseUrl/home/Home/admin');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return AdminHomeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load admin home: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Admin Home Error: $e');
    }
  }

  Future<WorkerHomeResponse> getWorkerHome(String token) async {
    final url = Uri.parse('$_baseUrl/home/Home/worker');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return WorkerHomeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load worker home: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Worker Home Error: $e');
    }
  }
}
