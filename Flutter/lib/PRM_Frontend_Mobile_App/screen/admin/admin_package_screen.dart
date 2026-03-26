import 'package:flutter/material.dart';
import '../../service/package_api_service.dart';
import '../../service/category_api_service.dart';
import '../../service/auth_helper.dart';
import '../../viewmodels/response/package_response.dart';
import '../../viewmodels/response/category_response.dart';

class AdminPackageScreen extends StatefulWidget {
  const AdminPackageScreen({Key? key}) : super(key: key);

  @override
  State<AdminPackageScreen> createState() => _AdminPackageScreenState();
}

class _AdminPackageScreenState extends State<AdminPackageScreen> {
  final PackageApiService _packageService = PackageApiService();
  final CategoryApiService _categoryService = CategoryApiService();
  List<PackageResponse> _packages = [];
  List<PackageResponse> _filteredPackages = [];
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  List<CategoryResponse> _categories = [];
  bool _isLoading = true;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initAuthAndLoad();
  }

  Future<void> _initAuthAndLoad() async {
    _accessToken = await AuthHelper.instance.getAccessToken();
    await _loadCategories();
    await _loadPackages();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories(accessToken: _accessToken);
      setState(() { _categories = categories; });
    } catch (e) {
      setState(() { _categories = []; });
    }
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final packages = await _packageService.getAllPackages(accessToken: _accessToken);
      setState(() {
        _packages = packages;
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

  void _applyFilter() {
    setState(() {
      if (_searchText.isEmpty) {
        _filteredPackages = List.from(_packages);
      } else {
        _filteredPackages = _packages.where((pkg) =>
          pkg.packageName.toLowerCase().contains(_searchText.toLowerCase()) ||
          (pkg.description ?? '').toLowerCase().contains(_searchText.toLowerCase())
        ).toList();
      }
    });
  }

  Future<void> _addPackageDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    CategoryResponse? selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm gói dịch vụ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CategoryResponse>(
                value: selectedCategory,
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.categoryName),
                )).toList(),
                onChanged: (cat) => selectedCategory = cat,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên gói')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
              TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Thời lượng (giờ)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thêm')),
        ],
      ),
    );
    if (result == true && selectedCategory != null) {
      try {
        final catId = selectedCategory?.categoryId ?? 0;
        await _packageService.createPackage(
          categoryId: catId,
          packageName: nameController.text,
          description: descController.text,
          price: double.tryParse(priceController.text) ?? 0,
          durationHours: int.tryParse(durationController.text) ?? 1,
          isActive: true,
          accessToken: _accessToken,
        );
        _loadPackages();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _editPackageDialog(PackageResponse package) async {
    final nameController = TextEditingController(text: package.packageName);
    final descController = TextEditingController(text: package.description ?? '');
    final priceController = TextEditingController(text: package.price.toString());
    final durationController = TextEditingController(text: package.durationHours.toString());
    CategoryResponse selectedCategory = _categories.isNotEmpty
      ? _categories.firstWhere((cat) => cat.categoryId == package.categoryId, orElse: () => _categories.first)
      : throw Exception('No categories available');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa gói dịch vụ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CategoryResponse>(
              value: selectedCategory,
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.categoryName),
              )).toList(),
              onChanged: (cat) => selectedCategory = cat,
              decoration: const InputDecoration(labelText: 'Danh mục'),
            ),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên gói')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
            TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Thời lượng (giờ)'), keyboardType: TextInputType.number),
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
        final catId = selectedCategory.categoryId;
        await _packageService.updatePackage(
          PackageResponse(
            packageId: package.packageId,
            categoryId: catId,
            packageName: nameController.text,
            description: descController.text,
            price: double.tryParse(priceController.text) ?? 0,
            durationHours: int.tryParse(durationController.text) ?? 1,
            isActive: package.isActive,
          ),
          accessToken: _accessToken,
        );
        _loadPackages();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deletePackage(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa gói dịch vụ'),
          ],
        ),
        content: const Text('Thao tác này sẽ xóa vĩnh viễn gói dịch vụ. Bạn có chắc chắn muốn tiếp tục?'),
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
        await _packageService.deletePackage(id, accessToken: _accessToken);
        _loadPackages();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thành công'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý gói dịch vụ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPackages,
              child: ListView.builder(
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return ListTile(
                    title: Text(package.packageName),
                    subtitle: Text('Giá: ${package.price} - ${package.description ?? ''}'),
                    onTap: () => _editPackageDialog(package),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePackage(package.packageId),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPackageDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
