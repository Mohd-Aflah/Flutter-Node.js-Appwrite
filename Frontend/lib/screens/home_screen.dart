import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';
import '../widgets/intern_form_dialog.dart';
import '../widgets/intern_details_dialog.dart';

/// Home screen with statistics, search, and intern management
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InternController controller = Get.put(InternController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 20), // Reduced from 16 : 24
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - responsive layout
          isMobile ? _buildMobileHeader(context) : _buildDesktopHeader(context),
          SizedBox(height: isMobile ? 16 : 24),

          // Statistics Cards
          Obx(() => _buildStatisticsCards(controller, isMobile)),
          SizedBox(height: isMobile ? 24 : 32),

          // Search and Filter Section
          _buildSearchAndFilters(controller, isMobile),
          SizedBox(height: isMobile ? 16 : 24),

          // Intern List
          Expanded(
            child: Obx(() => _buildInternList(context, controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open Navigation',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage interns, projects, and tasks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddInternDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Intern'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage interns, projects, and tasks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddInternDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Intern'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(InternController controller, bool isMobile) {
    final stats = controller.statistics;
    
    if (isMobile) {
      // Mobile layout: 2 cards per row
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Interns',
                  '${stats['totalInterns'] ?? 0}',
                  Icons.people_rounded,
                  Colors.blue,
                  isMobile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Projects',
                  '${stats['totalProjects'] ?? 0}',
                  Icons.folder_rounded,
                  Colors.orange,
                  isMobile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  '${stats['totalTasks'] ?? 0}',
                  Icons.task_rounded,
                  Colors.purple,
                  isMobile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed Tasks',
                  '${stats['completedTasks'] ?? 0}',
                  Icons.check_circle_rounded,
                  Colors.green,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    // Desktop layout: 4 cards in a row
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Interns',
            '${stats['totalInterns'] ?? 0}',
            Icons.people_rounded,
            Colors.blue,
            isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Projects',
            '${stats['totalProjects'] ?? 0}',
            Icons.folder_rounded,
            Colors.orange,
            isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Tasks',
            '${stats['totalTasks'] ?? 0}',
            Icons.task_rounded,
            Colors.purple,
            isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed Tasks',
            '${stats['completedTasks'] ?? 0}',
            Icons.check_circle_rounded,
            Colors.green,
            isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 10), // Reduced icon padding
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 18 : 22), // Reduced icon size
              ),
              Icon(
                Icons.trending_up_rounded,
                color: color,
                size: isMobile ? 14 : 16,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(InternController controller, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16), // Reduced from 16 : 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          
          if (isMobile) ...[
            // Mobile layout: Stack vertically
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or role...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: controller.searchInterns,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Batch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: controller.selectedBatch.value.isEmpty 
                        ? null 
                        : controller.selectedBatch.value,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Batches'),
                      ),
                      ...controller.availableBatches.map((batch) =>
                        DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch),
                        ),
                      ),
                    ],
                    onChanged: (value) => controller.filterByBatch(value ?? ''),
                  )),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Desktop layout: Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or role...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onChanged: controller.searchInterns,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Batch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: controller.selectedBatch.value.isEmpty 
                        ? null 
                        : controller.selectedBatch.value,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Batches'),
                      ),
                      ...controller.availableBatches.map((batch) =>
                        DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch),
                        ),
                      ),
                    ],
                    onChanged: (value) => controller.filterByBatch(value ?? ''),
                  )),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInternList(BuildContext context, InternController controller) {
    if (controller.isLoading.value && controller.interns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error.value.isNotEmpty && controller.interns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
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
              onPressed: controller.refreshInterns,
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No interns found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Add your first intern to get started'),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(context),
        crossAxisSpacing: MediaQuery.of(context).size.width < 768 ? 12 : 16,
        mainAxisSpacing: MediaQuery.of(context).size.width < 768 ? 12 : 16,
        childAspectRatio: MediaQuery.of(context).size.width < 768 ? 0.85 : 1.2,
      ),
      itemCount: controller.interns.length,
      itemBuilder: (context, index) {
        final intern = controller.interns[index];
        return _buildInternCard(context, intern, controller);
      },
    );
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 1; // Mobile: 1 column
    } else if (screenWidth < 900) {
      return 2; // Tablet: 2 columns
    } else if (screenWidth < 1200) {
      return 3; // Desktop small: 3 columns
    } else {
      return 4; // Desktop large: 4 columns
    }
  }

  Widget _buildInternCard(BuildContext context, Intern intern, InternController controller) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInternDetails(context, intern),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 20 : 24,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        intern.internName.isNotEmpty 
                            ? intern.internName[0].toUpperCase()
                            : 'I',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: isMobile ? 20 : 24,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showEditInternDialog(context, intern);
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(context, intern, controller);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  intern.internName.isNotEmpty ? intern.internName : 'Unnamed Intern',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  intern.batch.isNotEmpty ? intern.batch : 'No Batch',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (intern.roles.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 8 : 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: intern.roles.take(isMobile ? 2 : 3).map((role) => 
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
                if (intern.tasksAssigned.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 8 : 12),
                  Row(
                    children: [
                      Icon(
                        Icons.task_rounded,
                        size: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      Text(
                        '${intern.tasksAssigned.length} task${intern.tasksAssigned.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddInternDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InternFormDialog(),
    );
  }

  void _showEditInternDialog(BuildContext context, Intern intern) {
    showDialog(
      context: context,
      builder: (context) => InternFormDialog(intern: intern),
    );
  }

  /// Show intern details dialog with refresh capability
  /// Opens the comprehensive intern details dialog that shows overview, tasks, and projects
  /// Refreshes the intern list when changes are made (projects assigned, tasks updated)
  void _showInternDetails(BuildContext context, Intern intern) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => InternDetailsDialog(intern: intern),
    );

    // If changes were made, refresh the intern list to show updated data
    if (result == true) {
      final controller = Get.find<InternController>();
      controller.loadInterns(refresh: true);
    }
  }

  void _showDeleteConfirmation(BuildContext context, Intern intern, InternController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Intern'),
        content: Text('Are you sure you want to delete ${intern.internName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteIntern(intern.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
