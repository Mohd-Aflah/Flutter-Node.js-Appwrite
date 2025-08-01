import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../widgets/task_form_dialog.dart';
import '../config/app_config.dart';

/// Tasks screen showing all tasks with filtering and management
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedStatusFilter = 'all';
  String _selectedInternFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final InternController controller = Get.find<InternController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all tasks across interns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(context, controller),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Task Statistics
          Obx(() => _buildTaskStats(controller)),
          const SizedBox(height: 32),

          // Filters and Search
          _buildFiltersAndSearch(controller),
          const SizedBox(height: 24),

          // Tasks List
          Expanded(
            child: Obx(() => _buildTasksList(context, controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStats(InternController controller) {
    final allTasks = _getAllTasks(controller.interns);
    final completedTasks = allTasks.where((task) => task.status == 'completed').length;
    final openTasks = allTasks.where((task) => task.status == 'open').length;
    final workingTasks = allTasks.where((task) => task.status == 'working').length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Tasks',
            '${allTasks.length}',
            Icons.task_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '$completedTasks',
            Icons.check_circle_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'In Progress',
            '$workingTasks',
            Icons.pending_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Open',
            '$openTasks',
            Icons.radio_button_unchecked_rounded,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch(InternController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Search & Filter Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title or description...',
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Statuses'),
                    ),
                    ...AppConfig.taskStatuses.map((status) =>
                      DropdownMenuItem<String>(
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
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Intern Filter
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Intern',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedInternFilter,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Interns'),
                    ),
                    ...controller.interns.map((intern) =>
                      DropdownMenuItem<String>(
                        value: intern.id,
                        child: Text(intern.internName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedInternFilter = value!;
                    });
                  },
                )),
              ),
              const SizedBox(width: 16),
              
              // Clear Filters
              ElevatedButton.icon(
                onPressed: _clearFilters,
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
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, InternController controller) {
    final filteredTasks = _getFilteredTasks(controller.interns);

    if (filteredTasks.isEmpty) {
      return Center(
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
            const Text('Try adjusting your filters or add a new task'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final taskWithIntern = filteredTasks[index];
        return _buildTaskCard(context, taskWithIntern, controller);
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Map<String, dynamic> taskWithIntern,
    InternController controller,
  ) {
    final task = taskWithIntern['task'] as Task;
    final intern = taskWithIntern['intern'] as Intern;
    final statusColor = _getStatusColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
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
                
                // Actions
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showEditTaskDialog(context, task, intern.id),
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey[600],
                      ),
                      tooltip: 'Edit Task',
                    ),
                    PopupMenuButton<String>(
                      initialValue: task.status,
                      onSelected: (newStatus) => _updateTaskStatus(task, newStatus, intern.id),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Intern and Timestamp Info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    intern.internName.isNotEmpty
                        ? intern.internName[0].toUpperCase()
                        : 'I',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  intern.internName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    intern.batch,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const Spacer(),
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
          ],
        ),
      ),
    );
  }

  List<Task> _getAllTasks(List<Intern> interns) {
    final List<Task> allTasks = [];
    for (final intern in interns) {
      allTasks.addAll(intern.tasksAssigned);
    }
    return allTasks;
  }

  List<Map<String, dynamic>> _getFilteredTasks(List<Intern> interns) {
    final List<Map<String, dynamic>> tasksWithInterns = [];
    
    for (final intern in interns) {
      for (final task in intern.tasksAssigned) {
        tasksWithInterns.add({
          'task': task,
          'intern': intern,
        });
      }
    }

    // Apply filters
    return tasksWithInterns.where((item) {
      final task = item['task'] as Task;
      final intern = item['intern'] as Intern;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(searchLower) &&
            !task.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatusFilter != 'all' && task.status != _selectedStatusFilter) {
        return false;
      }

      // Intern filter
      if (_selectedInternFilter != 'all' && intern.id != _selectedInternFilter) {
        return false;
      }

      return true;
    }).toList()..sort((a, b) {
      final taskA = a['task'] as Task;
      final taskB = b['task'] as Task;
      return taskB.updatedAt.compareTo(taskA.updatedAt);
    });
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

  void _clearFilters() {
    setState(() {
      _selectedStatusFilter = 'all';
      _selectedInternFilter = 'all';
      _searchQuery = '';
    });
  }

  void _showAddTaskDialog(BuildContext context, InternController controller) {
    if (controller.interns.isEmpty) {
      Get.snackbar(
        'No Interns Available',
        'Please add interns first before creating tasks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _TaskWithInternSelectionDialog(controller: controller),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, String internId) {
    showDialog(
      context: context,
      builder: (context) => ImprovedTaskFormDialog(
        internId: internId,
        task: task,
      ),
    );
  }

  void _updateTaskStatus(Task task, String newStatus, String internId) {
    // TODO: Implement task status update
    Get.snackbar(
      'Task Updated',
      'Task "${task.title}" status changed to ${_capitalize(newStatus)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[50],
      colorText: Colors.green[800],
    );
  }
}

/// Dialog for adding a new task with intern selection
class _TaskWithInternSelectionDialog extends StatefulWidget {
  final InternController controller;

  const _TaskWithInternSelectionDialog({required this.controller});

  @override
  State<_TaskWithInternSelectionDialog> createState() => _TaskWithInternSelectionDialogState();
}

class _TaskWithInternSelectionDialogState extends State<_TaskWithInternSelectionDialog> {
  String? _selectedInternId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredInterns = widget.controller.interns.where((intern) {
      if (_searchQuery.isEmpty) return true;
      return intern.internName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             intern.id.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Intern for New Task',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search interns by name or ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Intern List
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: filteredInterns.length,
                itemBuilder: (context, index) {
                  final intern = filteredInterns[index];
                  final isSelected = _selectedInternId == intern.id;
                  
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                          ? Border.all(color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          intern.internName.isNotEmpty
                              ? intern.internName[0].toUpperCase()
                              : 'I',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      title: Text(intern.internName),
                      subtitle: Text('ID: ${intern.id} • Batch: ${intern.batch}'),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedInternId = intern.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedInternId != null ? _proceedToTaskForm : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToTaskForm() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => ImprovedTaskFormDialog(internId: _selectedInternId!),
    );
  }
}
