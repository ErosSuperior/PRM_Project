import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../service/worker_service.dart';
import '../../viewmodels/request/paginationRequest.dart';
import '../../viewmodels/response/userResponse.dart';

class WorkerListScreen extends StatefulWidget {
  final String categoryName;

  const WorkerListScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  // Existing state variables
  bool _isLoading = true;
  List<WorkerProfileResponse> _workers = [];
  late PaginationRequest _currentRequest;

  // --- NEW: Infinite Scroll State Variables ---
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMoreData = true;

  // Secure storage instance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Add the listener to detect when the user scrolls near the bottom
    _scrollController.addListener(_onScroll);
    _initializeRequestAndFetch();
  }

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If we are within 200 pixels of the bottom, fetch the next page
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isFetchingMore && _hasMoreData) {
        _fetchWorkersFromBackend(isLoadMore: true);
      }
    }
  }

  void _initializeRequestAndFetch() {
    // FORMAT REQUIREMENT: "CLEANING ETC" (all uppercase, spaces as dividers)
    // Example: "AC Repair" becomes "AC REPAIR"
    String formattedFilter = widget.categoryName.toUpperCase();

    // Initialize the DTO
    _currentRequest = PaginationRequest(
      pageNumber: 1,
      pageSize: 10,
      filterBy: formattedFilter,
    );

    _fetchWorkersFromBackend();
  }

  // --- UPDATED: Fetch method now handles both initial load and loading more ---
  Future<void> _fetchWorkersFromBackend({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isFetchingMore = true);
      _currentRequest.pageNumber++; // Ask for the next page
    } else {
      setState(() => _isLoading = true);
      _currentRequest.pageNumber = 1; // Reset to page 1
      _hasMoreData = true;
    }

    try {
      // Retrieve the auth token from secure storage
      String? authToken = await _secureStorage.read(key: 'access_token');
      
      if (authToken == null) {
        throw Exception('Authorization token not found. Please log in again.');
      }

      final workerService = WorkerService();
      final response = await workerService.getWorkerUsers(_currentRequest, authToken);

      setState(() {
        if (isLoadMore) {
          // APPEND new items to the existing list
          _workers.addAll(response.items);
          _isFetchingMore = false;
        } else {
          // REPLACE the list on initial load
          _workers = response.items;
          _isLoading = false;
        }

        // Check if we have hit the last page
        if (_currentRequest.pageNumber >= response.totalPages || response.items.isEmpty) {
          _hasMoreData = false;
        }
      });

    } catch (e) {
      // Handle the error gracefully
      setState(() {
        if (isLoadMore) {
          _isFetchingMore = false;
          _currentRequest.pageNumber--; // Revert the page number if it failed
        } else {
          _isLoading = false;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.categoryName} Workers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      // --- UPDATED: Body now uses the ScrollController and dynamic itemCount ---
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workers.isEmpty
          ? const Center(child: Text('No workers found for this category.'))
          : ListView.builder(
        controller: _scrollController, // Attach the scroll controller here
        padding: const EdgeInsets.all(16),
        // Add 1 to the count if we are fetching more, to make room for the loading spinner
        itemCount: _workers.length + (_isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // If we are at the end of the list and fetching more, show the spinner
          if (index == _workers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final worker = _workers[index];
          return _buildWorkerCard(worker);
        },
      ),
    );
  }

  Widget _buildWorkerCard(WorkerProfileResponse worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            backgroundImage: (worker.avatar != null && worker.avatar!.isNotEmpty)
                ? NetworkImage(worker.avatar!)
                : null,
            child: (worker.avatar == null || worker.avatar!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name ?? 'Unknown Worker',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.averageRating.toStringAsFixed(1)} (${worker.totalReviews} reviews)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${worker.experienceYears} years experience',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
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
