import 'package:flutter/material.dart';
import '../../service/category_api_service.dart';
import '../../service/auth_helper.dart';
import '../../viewmodels/response/category_response.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final CategoryApiService _categoryService = CategoryApiService();
  List<CategoryResponse> _categories = [];
  List<CategoryResponse> _filteredCategories = [];
  bool _isLoading = true;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initAuthAndLoad();
  }

  Future<void> _initAuthAndLoad() async {
    _accessToken = await AuthHelper.instance.getAccessToken();
    await _loadCategories();
  }

  void _applyFilter() {
    setState(() {
      if (_searchText.isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories.where((cat) =>
          cat.categoryName.toLowerCase().contains(_searchText.toLowerCase()) ||
          (cat.description ?? '').toLowerCase().contains(_searchText.toLowerCase())
        ).toList();
      }
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryService.getCategories(accessToken: _accessToken);
      setState(() {
        _categories = categories;
        _applyFilter();
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

  Future<void> _addCategoryDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên danh mục')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thêm')),
        ],
      ),
    );
    if (result == true) {
      try {
        await _categoryService.createCategory(nameController.text, description: descController.text, accessToken: _accessToken);
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _editCategoryDialog(CategoryResponse category) async {
    final nameController = TextEditingController(text: category.categoryName);
    final descController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên danh mục')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (result == true) {
      try {
        await _categoryService.updateCategory(category.categoryId, nameController.text, description: descController.text, accessToken: _accessToken);
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa danh mục'),
          ],
        ),
        content: const Text('Thao tác này sẽ xóa vĩnh viễn danh mục. Bạn có chắc chắn muốn tiếp tục?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _categoryService.deleteCategory(id, accessToken: _accessToken);
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục dịch vụ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm danh mục...',
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
                    onRefresh: _loadCategories,
                    child: ListView.builder(
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return ListTile(
                          title: Text(category.categoryName),
                          subtitle: Text(category.description ?? ''),
                          onTap: () => _editCategoryDialog(category),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category.categoryId),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
