import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/project_assignment_dialog.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

/// Dialog showing detailed intern information with task management
/// Provides comprehensive intern details including project assignment,
/// task management, and performance overview with enhanced UI
class InternDetailsDialog extends StatefulWidget {
  final Intern intern;

  const InternDetailsDialog({super.key, required this.intern});

  @override
  State<InternDetailsDialog> createState() => _InternDetailsDialogState();
}

class _InternDetailsDialogState extends State<InternDetailsDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTaskStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.intern.internName.isNotEmpty
                          ? widget.intern.internName[0].toUpperCase()
                          : 'I',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.intern.internName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.intern.id} • Batch: ${widget.intern.batch}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Tasks'),
              ],
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTasksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Roles Section
          _buildSection(
            'Roles',
            widget.intern.roles.isEmpty
                ? const Text('No roles assigned')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.intern.roles.map((role) =>
                      Chip(
                        label: Text(role),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ).toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // Projects Section with Assignment Button
          _buildSection(
            'Current Projects',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Projects list or empty state
                if (widget.intern.currentProjects.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No projects assigned',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...widget.intern.currentProjects.map((project) =>
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                          // TODO: Add unassign button
                          IconButton(
                            onPressed: () {
                              // Implement project unassignment
                              _showUnassignProjectDialog(project);
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            tooltip: 'Remove project',
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                
                const SizedBox(height: 12),
                
                // Assign Project Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showProjectAssignmentDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Assign Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Statistics
          _buildSection(
            'Task Statistics',
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Tasks',
                    '${widget.intern.tasksAssigned.length}',
                    Icons.task_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${widget.intern.completedTasksCount}',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    '${widget.intern.pendingTasksCount}',
                    Icons.pending_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final filteredTasks = _getFilteredTasks();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Task Filters and Add Button
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTaskFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      ...AppConfig.taskStatuses.map((status) =>
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTaskFilterChip(status, _capitalize(status)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Task'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Add a task to get started'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskFilterChip(String status, String label) {
    final isSelected = _selectedTaskStatus == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTaskStatus = status;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTaskCard(Task task) {
    final statusColor = _getStatusColor(task.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Edit Task Button
                    IconButton(
                      onPressed: () => _showEditTaskDialog(task),
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey[600],
                      ),
                      tooltip: 'Edit Task',
                    ),
                    
                    // Status Dropdown
                    PopupMenuButton<String>(
                      initialValue: task.status,
                      onSelected: (newStatus) => _updateTaskStatus(task, newStatus),
                      itemBuilder: (context) => AppConfig.taskStatuses.map((status) =>
                        PopupMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_capitalize(status)),
                            ],
                          ),
                        ),
                      ).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _capitalize(task.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned: ${_formatDate(task.assignedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.update_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${_formatDate(task.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _getFilteredTasks() {
    if (_selectedTaskStatus == 'all') {
      return widget.intern.tasksAssigned;
    }
    return widget.intern.tasksAssigned
        .where((task) => task.status == _selectedTaskStatus)
        .toList();
  }

  Color _getStatusColor(String status) {
    final colorHex = AppConfig.taskStatusColors[status] ?? '#2196F3';
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }

  String _capitalize(String text) {
    return text.isNotEmpty 
        ? text[0].toUpperCase() + text.substring(1).toLowerCase()
        : text;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show task form dialog for adding new tasks
  void _showAddTaskDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ImprovedTaskFormDialog(
        internId: widget.intern.id,
      ),
    );

    // If a task was added, refresh the parent dialog
    if (result == true) {
      Get.back(result: true);
    }
  }

  /// Show task form dialog for editing existing tasks
  void _showEditTaskDialog(Task task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ImprovedTaskFormDialog(
        internId: widget.intern.id,
        task: task,
      ),
    );

    // If the task was updated, refresh the parent dialog
    if (result == true) {
      Get.back(result: true);
    }
  }

  void _updateTaskStatus(Task task, String newStatus) {
    // TODO: Implement task status update
    // This would need to be implemented in the backend and controller
    Get.snackbar(
      'Task Updated',
      'Task "${task.title}" status changed to ${_capitalize(newStatus)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show project assignment dialog for this intern
  /// Opens a dialog that lists available projects and allows assignment
  void _showProjectAssignmentDialog() async {
    final result = await Get.dialog<bool>(
      ProjectAssignmentDialog(
        internId: widget.intern.id,
        internName: widget.intern.internName,
        currentProjectIds: widget.intern.currentProjects,
      ),
    );

    // If a project was assigned, refresh the parent dialog
    if (result == true) {
      // Close this dialog and notify parent to refresh
      Get.back(result: true);
    }
  }

  /// Show confirmation dialog for project unassignment
  /// Displays a confirmation dialog before removing a project from the intern
  void _showUnassignProjectDialog(String projectId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Project'),
        content: Text(
          'Are you sure you want to remove this project from ${widget.intern.internName}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _unassignProject(projectId);
    }
  }

  /// Unassign a project from the intern via API
  /// Makes the API call to remove the project and shows appropriate feedback
  Future<void> _unassignProject(String projectId) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Call API to unassign the project
      final apiService = ApiService();
      final success = await apiService.unassignProjectFromIntern(
        widget.intern.id,
        projectId,
      );

      // Close loading dialog
      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Project removed from ${widget.intern.internName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );

        // Close this dialog and notify parent to refresh
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Error',
          'Project was not assigned to this intern',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[50],
          colorText: Colors.orange[800],
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to remove project: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
      );
    }
  }
}
