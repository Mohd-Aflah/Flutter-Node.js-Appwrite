import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';
import '../config/app_config.dart';

/// Simplified dialog for creating and editing interns
class InternFormDialog extends StatefulWidget {
  final Intern? intern;

  const InternFormDialog({super.key, this.intern});

  @override
  State<InternFormDialog> createState() => _InternFormDialogState();
}

class _InternFormDialogState extends State<InternFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _internIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _projectController = TextEditingController();
  
  List<String> _selectedRoles = [];

  @override
  void initState() {
    super.initState();
    if (widget.intern != null) {
      _internIdController.text = widget.intern!.id;
      _nameController.text = widget.intern!.internName;
      _batchController.text = widget.intern!.batch;
      _projectController.text = widget.intern!.currentProjects.join(', ');
      _selectedRoles = List.from(widget.intern!.roles);
    }
  }

  @override
  void dispose() {
    _internIdController.dispose();
    _nameController.dispose();
    _batchController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.intern != null;
    
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450, // Reduced width
          maxHeight: MediaQuery.of(context).size.height * 0.75, // Reduced height
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // Reduced width
          padding: const EdgeInsets.all(16), // Reduced padding
          child: SingleChildScrollView( // Add scroll view to prevent overflow
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Intern' : 'Add New Intern',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Intern ID field (only for new interns)
                  if (!isEditing) ...[
                    TextFormField(
                      controller: _internIdController,
                      decoration: const InputDecoration(
                        labelText: 'Intern ID *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., INT001',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Intern ID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                  ],
                  
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Intern Name *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Batch field
                  TextFormField(
                    controller: _batchController,
                    decoration: const InputDecoration(
                      labelText: 'Batch *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 2025-Summer',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Batch is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Project field (NEW - replacing task assignment)
                  TextFormField(
                    controller: _projectController,
                    decoration: const InputDecoration(
                      labelText: 'Projects',
                      border: OutlineInputBorder(),
                      hintText: 'Enter project names separated by commas',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
              
                  
                  // Simplified Roles field
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Primary Role',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedRoles.isNotEmpty ? _selectedRoles.first : null,
                    items: AppConfig.availableRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRoles = value != null ? [value] : [];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<InternController>();

    // Parse projects from comma-separated string
    final projectsText = _projectController.text.trim();
    final currentProjects = projectsText.isNotEmpty 
        ? projectsText.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList()
        : <String>[];

    final intern = Intern(
      id: isEditing ? widget.intern!.id : _internIdController.text.trim(),
      internName: _nameController.text.trim(),
      batch: _batchController.text.trim(),
      roles: _selectedRoles,
      currentProjects: currentProjects,
      tasksAssigned: widget.intern?.tasksAssigned ?? [],
      createdAt: widget.intern?.createdAt,
      updatedAt: widget.intern?.updatedAt,
    );

    bool success;
    try {
      if (isEditing) {
        // Update existing intern
        success = await controller.updateIntern(widget.intern!.id, intern);
      } else {
        // Create new intern
        success = await controller.createIntern(intern);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        Get.snackbar(
          'Success',
          isEditing ? 'Intern updated successfully' : 'Intern created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${isEditing ? 'update' : 'create'} intern: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
      );
    }
  }

  bool get isEditing => widget.intern != null;
}
