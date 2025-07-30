import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';

/// Dialog for creating and editing interns
class InternFormDialog extends StatefulWidget {
  final Intern? intern;

  const InternFormDialog({super.key, this.intern});

  @override
  State<InternFormDialog> createState() => _InternFormDialogState();
}

class _InternFormDialogState extends State<InternFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _rolesController = TextEditingController();
  final _projectsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.intern != null) {
      _nameController.text = widget.intern!.internName;
      _batchController.text = widget.intern!.batch;
      _rolesController.text = widget.intern!.roles.join(', ');
      _projectsController.text = widget.intern!.currentProjects.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _rolesController.dispose();
    _projectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.intern != null;
    
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Intern' : 'Add New Intern',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Intern Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Batch field
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2025-Summer',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Batch is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Roles field
              TextFormField(
                controller: _rolesController,
                decoration: const InputDecoration(
                  labelText: 'Roles',
                  border: OutlineInputBorder(),
                  hintText: 'Frontend Developer, Backend Developer',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Current Projects field
              TextFormField(
                controller: _projectsController,
                decoration: const InputDecoration(
                  labelText: 'Current Projects',
                  border: OutlineInputBorder(),
                  hintText: 'E-commerce App, Mobile Development',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<InternController>();
    
    // Parse roles and projects from comma-separated strings
    final roles = _rolesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    final projects = _projectsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final intern = Intern(
      id: widget.intern?.id ?? '',
      internName: _nameController.text.trim(),
      batch: _batchController.text.trim(),
      roles: roles,
      currentProjects: projects,
      tasksAssigned: widget.intern?.tasksAssigned ?? [],
      createdAt: widget.intern?.createdAt,
      updatedAt: widget.intern?.updatedAt,
    );

    bool success;
    if (widget.intern != null) {
      // Update existing intern
      success = await controller.updateIntern(widget.intern!.id, intern);
    } else {
      // Create new intern
      success = await controller.createIntern(intern);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}
