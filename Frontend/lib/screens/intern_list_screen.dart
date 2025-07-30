import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/intern_form_dialog.dart';
import '../widgets/intern_list_item.dart';

/// Main screen displaying the list of interns
class InternListScreen extends StatelessWidget {
  const InternListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InternController controller = Get.put(InternController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Management System'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshInterns(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          const SearchFilterBar(),
          
          // Statistics Card
          Obx(() => _buildStatisticsCard(controller)),
          
          // Intern List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.interns.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.error.value.isNotEmpty && controller.interns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load interns',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.error.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.refreshInterns(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.interns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No interns found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first intern to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshInterns(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.interns.length + 
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.interns.length) {
                      // Load more indicator
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        // Load more button
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () => controller.loadMoreInterns(),
                              child: const Text('Load More'),
                            ),
                          ),
                        );
                      }
                    }

                    final intern = controller.interns[index];
                    return InternListItem(
                      intern: intern,
                      onEdit: () => _showInternDialog(context, intern),
                      onDelete: () => _showDeleteConfirmation(context, intern),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInternDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Intern'),
      ),
    );
  }

  Widget _buildStatisticsCard(InternController controller) {
    final stats = controller.statistics;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Interns',
              '${stats['totalInterns']}',
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Total Tasks',
              '${stats['totalTasks']}',
              Icons.task_alt,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Completed',
              '${stats['completedTasks']}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Avg Progress',
              '${(stats['averageProgress'] ?? 0).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showInternDialog(BuildContext context, Intern? intern) {
    showDialog(
      context: context,
      builder: (context) => InternFormDialog(intern: intern),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Intern intern) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Intern',
        message: 'Are you sure you want to delete "${intern.internName}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () {
          final controller = Get.find<InternController>();
          controller.deleteIntern(intern.id);
        },
      ),
    );
  }
}
