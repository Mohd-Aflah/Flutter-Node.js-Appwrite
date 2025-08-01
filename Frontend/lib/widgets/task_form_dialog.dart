import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../controllers/intern_controller.dart';

/// Dialog for creating and editing tasks with full database integration
/// Provides comprehensive task management functionality including creation,
/// editing, and validation with proper error handling and user feedback
class ImprovedTaskFormDialog extends StatefulWidget {
  /// The ID of the intern this task belongs to
  final String internId;
  
  /// The task to edit (null for creating new tasks)
  final Task? task;

  /// Constructor for the task form dialog
  /// [internId] - Required ID of the intern to assign/edit tasks for
  /// [task] - Optional existing task for editing mode
  const ImprovedTaskFormDialog({
    super.key,
    required this.internId,
    this.task,
  });

  @override
  State<ImprovedTaskFormDialog> createState() => _ImprovedTaskFormDialogState();
}

class _ImprovedTaskFormDialogState extends State<ImprovedTaskFormDialog> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Text controllers for form inputs
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  /// Currently selected task status
  String _selectedStatus = 'open';
  
  /// Loading state during form submission
  bool _isSubmitting = false;
  
  /// API service for making backend requests
  final ApiService _apiService = ApiService();
  
  /// Intern controller for updating the UI after task changes
  final InternController _internController = Get.find<InternController>();

  @override
  void initState() {
    super.initState();
    
    // If editing an existing task, populate the form fields
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500, // Reduced from 600
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Reduced from 0.9
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, // Reduced from 0.9
          padding: const EdgeInsets.all(20), // Reduced from 24
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header with icon and title
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.add_task,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Task' : 'Add New Task',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'for this intern',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Task Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  border: const OutlineInputBorder(),
                  hintText: 'Enter a clear, descriptive task title',
                  prefixIcon: const Icon(Icons.title),
                  helperText: 'Be specific about what needs to be accomplished',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters long';
                  }
                  if (value.length > 100) {
                    return 'Title too long (max 100 characters)';
                  }
                  return null;
                },
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 16),

              // Task Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: const OutlineInputBorder(),
                  hintText: 'Provide detailed instructions and requirements',
                  prefixIcon: const Icon(Icons.description),
                  helperText: 'Include context, deliverables, and any special requirements',
                ),
                maxLines: 4,
                minLines: 3,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Description too long (max 500 characters)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Task Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Task Status *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flag),
                  helperText: 'Set the current state of this task',
                ),
                items: AppConfig.taskStatuses.map((status) {
                  final statusColor = _getStatusColor(status);
                  final statusDescription = _getStatusDescription(status);
                  
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _capitalize(status),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                statusDescription,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a task status';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Update Task' : 'Create Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Get color for task status indicator
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

  /// Get description for task status
  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Ready to be started';
      case 'todo':
        return 'Planned for future work';
      case 'working':
        return 'Currently in progress';
      case 'pending':
        return 'Waiting for dependencies';
      case 'deferred':
        return 'Postponed to later';
      case 'completed':
        return 'Finished successfully';
      default:
        return 'Task status';
    }
  }

  /// Capitalize first letter of status name
  String _capitalize(String text) {
    return text.isNotEmpty 
        ? text[0].toUpperCase() + text.substring(1).toLowerCase()
        : text;
  }

  /// Submit the form and save task to database
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create the task object
      final task = widget.task?.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      ) ?? Task.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
      );

      // Save to database via API
      bool success;
      if (widget.task != null) {
        // Update existing task
        success = await _apiService.updateTaskForIntern(widget.internId, task);
      } else {
        // Create new task
        success = await _apiService.addTaskToIntern(widget.internId, task);
      }

      if (success) {
        // Refresh the intern controller to update the UI
        await _internController.loadInterns(refresh: true);
        
        // Show success message
        Get.snackbar(
          'Success',
          widget.task != null
              ? 'Task "${task.title}" updated successfully'
              : 'Task "${task.title}" created and assigned successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        throw Exception('Failed to save task to database');
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to save task: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
