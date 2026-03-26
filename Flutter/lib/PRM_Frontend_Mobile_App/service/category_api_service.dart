import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/response/category_response.dart';

class CategoryApiService {
  final String _baseUrl = AppSetting.apiUrl.endsWith('/') 
      ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1) 
      : AppSetting.apiUrl;

  Future<CategoryResponse> createCategory(String name, {String? description, String? accessToken}) async {
    final url = Uri.parse('$_baseUrl/api/ServiceCategory');
    final body = jsonEncode({
      'categoryName': name,
      if (description != null) 'description': description,
    });
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 201) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  }

  Future<void> updateCategory(int id, String name, {String? description, String? accessToken}) async {
    final url = Uri.parse('$_baseUrl/api/ServiceCategory/$id');
    final body = jsonEncode({
      'categoryId': id,
      'categoryName': name,
      if (description != null) 'description': description,
    });
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update category: ${response.statusCode}');
    }
  }

  Future<void> deleteCategory(int id, {String? accessToken}) async {
    final url = Uri.parse('$_baseUrl/api/ServiceCategory/$id');
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final response = await http.delete(
      url,
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  }

  Future<List<CategoryResponse>> getCategories({String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/api/ServiceCategory');
      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CategoryResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
