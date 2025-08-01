import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/intern.dart';
import '../services/api_service.dart';

/// Controller for managing intern data and operations using GetX
class InternController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable lists and variables
  final RxList<Intern> interns = <Intern>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;
  final RxInt totalCount = 0.obs;
  final RxMap<String, int> taskSummary = <String, int>{}.obs;

  // Filter and search variables
  final RxString searchQuery = ''.obs;
  final RxString selectedBatch = ''.obs;
  final RxList<String> availableBatches = <String>[].obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    // Use Future.delayed to ensure widget is built before loading
    Future.delayed(const Duration(milliseconds: 100), () {
      loadInterns();
      loadTaskSummary();
    });
  }

  /// Load interns with optional filters
  Future<void> loadInterns({bool refresh = false}) async {
    try {
      if (refresh) {
        isRefreshing.value = true;
        currentPage.value = 0;
        hasMore.value = true;
        error.value = ''; // Clear previous errors on refresh
      } else {
        isLoading.value = true;
        error.value = ''; // Clear previous errors
      }

      final loadedInterns = await _apiService.getAllInterns(
        batch: selectedBatch.value.isNotEmpty ? selectedBatch.value : null,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        limit: pageSize,
        offset: currentPage.value * pageSize,
        sort: 'createdAt',
        order: 'desc',
      );

      if (refresh || currentPage.value == 0) {
        interns.value = loadedInterns;
      } else {
        interns.addAll(loadedInterns);
      }

      // Update available batches
      _updateAvailableBatches();

      // Check if there are more items
      hasMore.value = loadedInterns.length == pageSize;

      // Load total count only if we don't have errors
      await loadTotalCount();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      
      // Only show snackbar if it's not the initial load to avoid spam
      if (refresh || currentPage.value > 0) {
        Get.snackbar(
          'Error',
          'Failed to load interns: ${error.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[50],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Load more interns for pagination
  Future<void> loadMoreInterns() async {
    if (!hasMore.value || isLoading.value) return;

    currentPage.value++;
    await loadInterns();
  }

  /// Refresh the intern list
  Future<void> refreshInterns() async {
    await loadInterns(refresh: true);
  }

  /// Search interns by name
  void searchInterns(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
    loadInterns(refresh: true);
  }

  /// Filter interns by batch
  void filterByBatch(String batch) {
    selectedBatch.value = batch;
    currentPage.value = 0;
    loadInterns(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedBatch.value = '';
    currentPage.value = 0;
    loadInterns(refresh: true);
  }

  /// Create a new intern
  Future<bool> createIntern(Intern intern) async {
    try {
      isLoading.value = true;
      error.value = '';

      final createdIntern = await _apiService.createIntern(intern);
      
      // Add to the beginning of the list
      interns.insert(0, createdIntern);
      totalCount.value++;

      Get.snackbar(
        'Success',
        'Intern "${createdIntern.internName}" created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh task summary
      await loadTaskSummary();

      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create intern: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing intern
  Future<bool> updateIntern(String internId, Intern updatedIntern) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updated = await _apiService.updateIntern(internId, updatedIntern);
      
      // Update in the list
      final index = interns.indexWhere((intern) => intern.id == internId);
      if (index != -1) {
        interns[index] = updated;
      }

      Get.snackbar(
        'Success',
        'Intern "${updated.internName}" updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh task summary
      await loadTaskSummary();

      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update intern: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete an intern
  Future<bool> deleteIntern(String internId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _apiService.deleteIntern(internId);
      
      // Remove from the list
      final removedIntern = interns.firstWhere((intern) => intern.id == internId);
      interns.removeWhere((intern) => intern.id == internId);
      totalCount.value--;

      Get.snackbar(
        'Success',
        'Intern "${removedIntern.internName}" deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh task summary
      await loadTaskSummary();

      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete intern: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load total intern count
  Future<void> loadTotalCount() async {
    try {
      final count = await _apiService.getInternCount();
      totalCount.value = count;
    } catch (e) {
      // Don't show error for count, it's not critical
      // Failed to load total count: $e
    }
  }

  /// Load task summary
  Future<void> loadTaskSummary() async {
    try {
      final summary = await _apiService.getTaskSummary();
      taskSummary.value = summary;
    } catch (e) {
      // Don't show error for summary, it's not critical
      // Failed to load task summary: $e
    }
  }

  /// Get intern by ID
  Intern? getInternById(String id) {
    try {
      return interns.firstWhere((intern) => intern.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update available batches from current interns
  void _updateAvailableBatches() {
    final batches = interns.map((intern) => intern.batch).toSet().toList();
    batches.sort();
    availableBatches.value = batches;
  }

  /// Get filtered interns (for UI display without affecting main list)
  List<Intern> get filteredInterns {
    return interns.where((intern) {
      final matchesSearch = searchQuery.value.isEmpty ||
          intern.internName.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesBatch = selectedBatch.value.isEmpty ||
          intern.batch == selectedBatch.value;
      return matchesSearch && matchesBatch;
    }).toList();
  }

  /// Get interns by task status
  List<Intern> getInternsByTaskStatus(String status) {
    return interns.where((intern) {
      return intern.tasksAssigned.any((task) => task.status == status);
    }).toList();
  }

  /// Get statistics about interns and tasks
  Map<String, num> get statistics {
    final totalInterns = interns.length;
    final totalTasks = interns.fold<int>(0, (sum, intern) => sum + intern.tasksAssigned.length);
    final completedTasks = interns.fold<int>(0, (sum, intern) {
      return sum + intern.tasksAssigned.where((task) => task.status == 'completed').length;
    });
    
    final progressValues = interns.map((intern) {
      if (intern.tasksAssigned.isEmpty) return 0.0;
      final completed = intern.tasksAssigned.where((task) => task.status == 'completed').length;
      return (completed / intern.tasksAssigned.length) * 100;
    }).toList();
    
    final averageProgress = progressValues.isEmpty 
        ? 0.0 
        : progressValues.reduce((a, b) => a + b) / progressValues.length;

    return {
      'totalInterns': totalInterns,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'averageProgress': averageProgress,
    };
  }

  @override
  void onClose() {
    _apiService.dispose();
    super.onClose();
  }
}
