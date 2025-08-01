import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';
import '../config/app_config.dart';

/// Dialog for creating and editing interns
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
  
  List<String> _selectedRoles = [];

  @override
  void initState() {
    super.initState();
    if (widget.intern != null) {
      _internIdController.text = widget.intern!.id;
      _nameController.text = widget.intern!.internName;
      _batchController.text = widget.intern!.batch;
      _selectedRoles = List.from(widget.intern!.roles);
    }
  }

  @override
  void dispose() {
    _internIdController.dispose();
    _nameController.dispose();
    _batchController.dispose();
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
              
              // Intern ID field (only for new interns)
              if (!isEditing) ...[
                TextFormField(
                  controller: _internIdController,
                  decoration: const InputDecoration(
                    labelText: 'Intern ID *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., INT001',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Intern ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
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
              
              // Roles multi-select field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MultiSelectDialogField<String>(
                      items: AppConfig.availableRoles
                          .map((role) => MultiSelectItem<String>(role, role))
                          .toList(),
                      title: const Text('Select Roles'),
                      selectedColor: Theme.of(context).primaryColor,
                      decoration: const BoxDecoration(),
                      buttonIcon: const Icon(Icons.arrow_drop_down),
                      buttonText: Text(
                        _selectedRoles.isEmpty 
                            ? 'Select roles' 
                            : '${_selectedRoles.length} role(s) selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onConfirm: (results) {
                        setState(() {
                          _selectedRoles = results;
                        });
                      },
                      initialValue: _selectedRoles,
                      searchable: true,
                      searchHint: 'Search roles...',
                    ),
                  ),
                  if (_selectedRoles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedRoles.map((role) {
                        return Chip(
                          label: Text(
                            role,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedRoles.remove(role);
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
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

    final intern = Intern(
      id: isEditing ? widget.intern!.id : _internIdController.text.trim(),
      internName: _nameController.text.trim(),
      batch: _batchController.text.trim(),
      roles: _selectedRoles,
      currentProjects: widget.intern?.currentProjects ?? [],
      tasksAssigned: widget.intern?.tasksAssigned ?? [],
      createdAt: widget.intern?.createdAt,
      updatedAt: widget.intern?.updatedAt,
    );

    bool success;
    if (isEditing) {
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

  bool get isEditing => widget.intern != null;
}
