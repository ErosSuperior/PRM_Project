import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/appsetting.dart';
import '../viewmodels/request/authorizationRequest.dart';
import '../viewmodels/request/userRequest.dart';
import '../viewmodels/response/authorizationResponse.dart';
import '../viewmodels/response/userResponse.dart';

class AuthService {

  Future<void> activateUser(int userId) async {
    final url = Uri.parse('$_baseUrl/api/Admin/user/activate/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to activate user: ${response.statusCode}');
    }
  }

  Future<void> deactivateUser(int userId) async {
    final url = Uri.parse('$_baseUrl/api/Admin/user/deactivate/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to deactivate user: ${response.statusCode}');
    }
  }

    Future<List<UserProfileResponse>> getAllUsers() async {
      final url = Uri.parse('${_baseUrl}/api/Admin/users');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserProfileResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    }
  final String _baseUrl = AppSetting.apiUrl.endsWith('/') 
      ? AppSetting.apiUrl.substring(0, AppSetting.apiUrl.length - 1) 
      : AppSetting.apiUrl;

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$_baseUrl/auth/Authorization/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) throw Exception('Empty response body');
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  Future<dynamic> getProfile(String token, {int? userId}) async {
    final queryParams = userId != null ? '?userId=$userId' : '';
    final url = Uri.parse('$_baseUrl/user/UserManagement/profile$queryParams');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Check if it's a worker profile based on the presence of worker-specific fields
        if (data.containsKey('experienceYears') || data.containsKey('ExperienceYears')) {
          return WorkerProfileResponse.fromJson(data);
        } else {
          return UserProfileResponse.fromJson(data);
        }
      } else {
        throw Exception('Profile Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateProfile(String token, UpdateUserProfileRequest request) async {
    final url = Uri.parse('$_baseUrl/user/UserManagement/profile');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Update Profile Error: $e');
    }
  }

  Future<void> updateWorkerProfile(String token, UpdateWorkerProfileRequest request) async {
    final url = Uri.parse('$_baseUrl/user/UserManagement/profile/worker');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Update Worker Profile Error: $e');
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Error: ${response.statusCode}';
    } catch (_) {
      return 'Error: ${response.statusCode}';
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('$_baseUrl/auth/Authorization/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_parseErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Registration Error: $e');
    }
  }
}
