import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../service/authenticationService.dart';
import '../../viewmodels/request/userRequest.dart';
import '../../viewmodels/response/userResponse.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = true;
  dynamic _profile; // Can be UserProfileResponse or WorkerProfileResponse

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No token found');

      final profileData = await _authService.getProfile(token);
      setState(() {
        _profile = profileData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _secureStorage.delete(key: 'access_token');
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showUpdateDialog() {
    final nameController = TextEditingController(text: _profile.name);
    final phoneController = TextEditingController(text: _profile.phone);
    final addressController = TextEditingController(text: _profile.address);
    
    // Worker specific status
    bool isAvailable = false;

    if (_profile is WorkerProfileResponse) {
      final worker = _profile as WorkerProfileResponse;
      isAvailable = worker.isAvailable;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                if (_profile is WorkerProfileResponse) ...[
                  SwitchListTile(
                    title: const Text('Available for work'),
                    contentPadding: EdgeInsets.zero,
                    value: isAvailable,
                    onChanged: (val) => setDialogState(() => isAvailable = val),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  isAvailable: _profile is WorkerProfileResponse ? isAvailable : null,
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile({
    required String name,
    required String phone,
    required String address,
    bool? isAvailable,
  }) async {
    setState(() => _isLoading = true);
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No token found');

      if (_profile is WorkerProfileResponse) {
        final request = UpdateWorkerProfileRequest(
          baseProfile: UpdateUserProfileRequest(
            name: name,
            phone: phone,
            address: address,
          ),
          isAvailable: isAvailable,
          // Removed experienceYears and bio as requested
        );
        await _authService.updateWorkerProfile(token, request);
      } else {
        final request = UpdateUserProfileRequest(
          name: name,
          phone: phone,
          address: address,
        );
        await _authService.updateProfile(token, request);
      }

      await _fetchProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profile == null
            ? const Center(child: Text('Unable to load profile'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (Navigator.canPop(context)) const SizedBox(width: 12),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: _showUpdateDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- AVATAR & BASIC INFO ---
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: (_profile.avatar != null && _profile.avatar!.isNotEmpty)
                            ? NetworkImage(_profile.avatar!)
                            : null,
                        child: (_profile.avatar == null || _profile.avatar!.isEmpty)
                            ? const Icon(Icons.person, size: 60, color: Colors.blueAccent)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile.name ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile.email ?? 'No Email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- INFO SECTION ---
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(Icons.phone, 'Phone', _profile.phone ?? 'Not provided', Colors.blue),
              const SizedBox(height: 12),
              _buildInfoCard(Icons.location_on, 'Address', _profile.address ?? 'Not provided', Colors.redAccent),

              // Worker Specific Fields
              if (_profile is WorkerProfileResponse) ...[
                const SizedBox(height: 32),
                const Text(
                  'Worker Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 16),
                _buildInfoCard(Icons.work, 'Experience', '${(_profile as WorkerProfileResponse).experienceYears} Years', Colors.orange),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.star, 'Rating', '${(_profile as WorkerProfileResponse).averageRating.toStringAsFixed(1)} (${(_profile as WorkerProfileResponse).totalReviews} reviews)', Colors.amber),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.info_outline, 'Bio', (_profile as WorkerProfileResponse).bio, Colors.teal),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.check_circle_outline, 'Status', (_profile as WorkerProfileResponse).isAvailable ? 'Available' : 'Busy', (_profile as WorkerProfileResponse).isAvailable ? Colors.green : Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
