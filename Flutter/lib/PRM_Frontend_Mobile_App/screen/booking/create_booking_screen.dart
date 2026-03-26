import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../service/booking_api_service.dart';
import '../../service/category_api_service.dart';
import '../../service/auth_helper.dart';
import '../../viewmodels/request/bookingRequest.dart';
import '../../viewmodels/response/userResponse.dart';
import '../../viewmodels/response/category_response.dart';

class ServicePackage {
  final String id;
  final String label;
  final double price;

  ServicePackage({required this.id, required this.label, required this.price});
}

class CreateBookingScreen extends StatefulWidget {
  final WorkerProfileResponse? worker;
  final String? categoryName;

  const CreateBookingScreen({Key? key, this.worker, this.categoryName}) : super(key: key);

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  LatLng? _currentPosition;
  String _currentAddress = "Locating...";
  bool _isLocating = true;
  bool _isSubmitting = false;
  bool _isSearching = false;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 2));
  
  List<CategoryResponse> _categories = [];
  CategoryResponse? _selectedCategory;
  bool _isLoadingCategories = true;

  final List<ServicePackage> _packages = [
    ServicePackage(id: '1', label: '1 - 50k', price: 50000),
    ServicePackage(id: '2', label: '2 - 100k', price: 100000),
    ServicePackage(id: '3', label: '3 - 200k', price: 200000),
    ServicePackage(id: '4', label: '4 - 500k', price: 500000),
    ServicePackage(id: '5', label: '5 - Deal', price: 0),
  ];
  ServicePackage? _selectedPackage;
  
  final BookingApiService _apiService = BookingApiService();
  final CategoryApiService _categoryService = CategoryApiService();
  final AuthHelper _authHelper = AuthHelper.instance;

  @override
  void initState() {
    super.initState();
    _selectedPackage = _packages[0];
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
          
          if (widget.categoryName != null) {
            _selectedCategory = _categories.firstWhere(
              (c) => c.categoryName.toLowerCase() == widget.categoryName!.toLowerCase(),
              orElse: () => _categories.isNotEmpty ? _categories.first : categories[0],
            );
          } else if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _currentAddress = "Location services disabled"; _isLocating = false; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() { _currentAddress = "Permission denied"; _isLocating = false; });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        desiredAccuracy: LocationAccuracy.high,
      );
      
      LatLng userLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = userLatLng;
          _isLocating = false;
        });
        _mapController.move(userLatLng, 15.0);
        _getAddressFromLatLng(userLatLng);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Please tap to pick location";
          _currentPosition = const LatLng(21.0285, 105.8542);
          _isLocating = false;
        });
        _mapController.move(const LatLng(21.0285, 105.8542), 15.0);
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1');
    
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'HomeServiceApp/1.0' 
      });

      if (response.statusCode == 200 && mounted) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final LatLng newPos = LatLng(lat, lon);
          
          setState(() {
            _currentPosition = newPos;
            _currentAddress = data[0]['display_name'];
            _isSearching = false;
          });
          _mapController.move(newPos, 15.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
          setState(() => _isSearching = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;
    setState(() => _currentAddress = "Fetching address...");
    
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
    
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'HomeServiceApp/1.0' 
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _currentAddress = data['display_name'] ?? "Unknown address";
          _searchController.text = _currentAddress;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "Failed to load address");
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _authHelper.getAccessToken();
      final customerId = await _authHelper.getCurrentCustomerId();

      if (token == null || customerId == null) throw Exception('User not authenticated');

      final dateStr = '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')}';
      final timeStr = '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}:00';

      // packageId logic: packageId + "-" + categoryName
      final packageIdStr = "${_selectedPackage!.id}-${_selectedCategory?.categoryName ?? 'Service'}";

      final request = CreateBookingRequest(
        customerId: customerId,
        workerId: 6,
        packageId: packageIdStr, 
        bookingDate: dateStr,
        startTime: timeStr,
        address: _currentAddress,
        note: _notesController.text.trim(),
        totalPrice: _selectedPackage!.price > 0 ? _selectedPackage!.price : null,
      );

      await _apiService.createBooking(request, accessToken: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for address...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    suffixIcon: _isSearching 
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)))
                        : IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),

            // --- MAP SECTION ---
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition ?? const LatLng(21.0285, 105.8542),
                      initialZoom: 15.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture && position.center != null) {
                          _currentPosition = position.center!;
                        }
                      },
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd && _currentPosition != null) {
                           _getAddressFromLatLng(_currentPosition!);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.projectprm.app',
                      ),
                      if (_currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (_isLocating)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                  // --- FLOATING BUTTONS ---
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: "btn1",
                          mini: true,
                          onPressed: _determinePosition,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.my_location, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: "btn2",
                          mini: true,
                          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: "btn3",
                          mini: true,
                          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Service Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_currentAddress, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (widget.worker != null) ...[
                      const Text('Selected Worker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: (widget.worker!.avatar != null) ? NetworkImage(widget.worker!.avatar!) : null,
                          child: (widget.worker!.avatar == null) ? const Icon(Icons.person) : null,
                        ),
                        title: Text(widget.worker!.name ?? 'Worker'),
                        subtitle: Text('${widget.worker!.experienceYears} years experience'),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Text('Service Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _isLoadingCategories 
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<CategoryResponse>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: _categories.map((c) => DropdownMenuItem(
                            value: c, 
                            child: Text(c.categoryName)
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          validator: (value) => value == null ? 'Please select a category' : null,
                        ),
                    const SizedBox(height: 16),
                    
                    // NEW: Package Picker
                    DropdownButtonFormField<ServicePackage>(
                      value: _selectedPackage,
                      decoration: const InputDecoration(labelText: 'Package', border: OutlineInputBorder()),
                      items: _packages.map((p) => DropdownMenuItem(
                        value: p, 
                        child: Text(p.label)
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedPackage = val),
                      validator: (value) => value == null ? 'Please select a package' : null,
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _pickDateTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date & Time', border: OutlineInputBorder()),
                        child: Text('${_selectedDateTime.day}/${_selectedDateTime.month} at ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes for worker', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _isLoadingCategories) ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
