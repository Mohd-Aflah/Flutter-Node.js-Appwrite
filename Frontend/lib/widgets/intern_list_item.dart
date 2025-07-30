import 'package:flutter/material.dart';
import '../models/intern.dart';

/// Widget representing a single intern item in the list
class InternListItem extends StatelessWidget {
  final Intern intern;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InternListItem({
    super.key,
    required this.intern,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intern.internName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batch: ${intern.batch}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Roles
            if (intern.roles.isNotEmpty) ...[
              Text(
                'Roles:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: intern.roles.map((role) => Chip(
                  label: Text(
                    role,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // Current Projects
            if (intern.currentProjects.isNotEmpty) ...[
              Text(
                'Current Projects:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: intern.currentProjects.map((project) => Chip(
                  label: Text(
                    project,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green[50],
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // Tasks Summary
            if (intern.tasksAssigned.isNotEmpty) ...[
              Text(
                'Tasks:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _getTaskProgress(),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(_getTaskProgress() * 100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_getTaskProgress() * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Task status badges
              _buildTaskStatusBadges(),
            ] else ...[
              Text(
                'No tasks assigned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getTaskProgress() {
    if (intern.tasksAssigned.isEmpty) return 0.0;
    final completedTasks = intern.tasksAssigned
        .where((task) => task.status == 'completed')
        .length;
    return completedTasks / intern.tasksAssigned.length;
  }

  Widget _buildTaskStatusBadges() {
    final statusCounts = <String, int>{};
    
    for (final task in intern.tasksAssigned) {
      statusCounts[task.status] = (statusCounts[task.status] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: statusCounts.entries.map((entry) {
        final status = entry.key;
        final count = entry.value;
        final color = _getStatusColor(status);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$status ($count)',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 25) return Colors.yellow[700]!;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'working':
        return Colors.blue;
      case 'todo':
        return Colors.orange;
      case 'pending':
        return Colors.purple;
      case 'deferred':
        return Colors.grey;
      case 'open':
      default:
        return Colors.red;
    }
  }
}
