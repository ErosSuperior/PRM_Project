import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/response/package_response.dart';

class PackageApiService {

    Future<PackageResponse> createPackage({
      required int categoryId,
      required String packageName,
      String? description,
      required double price,
      required int durationHours,
      bool? isActive,
      String? accessToken,
    }) async {
      final url = Uri.parse('$_baseUrl/api/ServicePackage');
      final body = jsonEncode({
        'categoryId': categoryId,
        'packageName': packageName,
        if (description != null) 'description': description,
        'price': price,
        'durationHours': durationHours,
        if (isActive != null) 'isActive': isActive,
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
        return PackageResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create package: ${response.statusCode}');
      }
    }

    Future<void> updatePackage(PackageResponse package, {String? accessToken}) async {
      final url = Uri.parse('$_baseUrl/api/ServicePackage/${package.packageId}');
      final body = jsonEncode({
        'packageId': package.packageId,
        'categoryId': package.categoryId,
        'packageName': package.packageName,
        'description': package.description,
        'price': package.price,
        'durationHours': package.durationHours,
        'isActive': package.isActive,
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
        throw Exception('Failed to update package: ${response.statusCode}');
      }
    }

    Future<void> deletePackage(int id, {String? accessToken}) async {
      final url = Uri.parse('$_baseUrl/api/ServicePackage/$id');
      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
      final response = await http.delete(
        url,
        headers: headers,
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete package: ${response.statusCode}');
      }
    }
  final String _baseUrl = AppSetting.apiUrl.endsWith('/') 
      ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1) 
      : AppSetting.apiUrl;

  Future<List<PackageResponse>> getPackagesByCategory(int categoryId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/ServicePackage/category/$categoryId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PackageResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching packages: $e');
    }
  }

  Future<List<PackageResponse>> getAllPackages({String? accessToken}) async {
    try {
      final url = Uri.parse('$_baseUrl/api/ServicePackage');
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
        return data.map((json) => PackageResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching packages: $e');
    }
  }
}
