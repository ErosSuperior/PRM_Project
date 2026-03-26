import 'package:flutter/material.dart';
import '../../service/authenticationService.dart';
import '../../viewmodels/response/userResponse.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final AuthService _authService = AuthService();
  List<UserProfileResponse> _users = [];
  List<UserProfileResponse> _filteredUsers = [];
  bool _isLoading = true;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  void _applyFilter() {
    setState(() {
      if (_searchText.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users.where((user) =>
          (user.name ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
          (user.email ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
          (user.phone ?? '').toLowerCase().contains(_searchText.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _authService.getAllUsers();
      setState(() {
        _users = users;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleActive(int userIndex, bool value) async {
    final user = _users[userIndex];
    bool confirmed = true;
    if (!value) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Xác nhận vô hiệu hóa'),
            ],
          ),
          content: Text('Bạn có chắc chắn muốn vô hiệu hóa tài khoản của ${user.name ?? user.email}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Vô hiệu hóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ?? false;
    }
    if (!value && !confirmed) return;
    try {
      if (value) {
        await _authService.activateUser(user.id!);
      } else {
        await _authService.deactivateUser(user.id!);
      }
      setState(() {
        _users[userIndex] = UserProfileResponse(
          name: user.name,
          email: user.email,
          phone: user.phone,
          address: user.address,
          avatar: user.avatar,
          isActive: value,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý tài khoản người dùng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm người dùng...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _applyFilter();
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          title: Text(user.name ?? ''),
                          subtitle: Text(user.email ?? ''),
                          trailing: Switch(
                            value: user.isActive ?? true,
                            onChanged: (val) => _toggleActive(index, val),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
