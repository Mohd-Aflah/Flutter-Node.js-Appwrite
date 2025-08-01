import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/project.dart';
import '../services/api_service.dart';

/// Dialog widget for assigning projects to interns
/// Provides a searchable list of available projects with assign functionality
/// Displays project details including status, priority, and available slots
class ProjectAssignmentDialog extends StatefulWidget {
  /// The ID of the intern to assign projects to
  final String internId;
  
  /// The name of the intern for display purposes
  final String internName;
  
  /// List of currently assigned project IDs to filter out
  final List<String> currentProjectIds;

  /// Constructor for the project assignment dialog
  /// [internId] - Required ID of the intern
  /// [internName] - Required name for display in dialog title
  /// [currentProjectIds] - List of already assigned project IDs
  const ProjectAssignmentDialog({
    super.key,
    required this.internId,
    required this.internName,
    this.currentProjectIds = const [],
  });

  @override
  State<ProjectAssignmentDialog> createState() => _ProjectAssignmentDialogState();
}

class _ProjectAssignmentDialogState extends State<ProjectAssignmentDialog> {
  /// API service instance for making project-related requests
  final ApiService _apiService = ApiService();
  
  /// List of all available projects from the backend
  List<Project> _allProjects = [];
  
  /// Filtered list of projects based on search and assignment status
  List<Project> _filteredProjects = [];
  
  /// Loading state indicator
  bool _isLoading = true;
  
  /// Error message if loading fails
  String _error = '';
  
  /// Search query for filtering projects
  String _searchQuery = '';
  
  /// Text controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    
    // Listen to search input changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterProjects();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load all projects from the backend
  /// Filters out already assigned projects and inactive projects
  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Get all active projects from the backend
      final projects = await _apiService.getAllProjects(status: 'active');
      
      setState(() {
        _allProjects = projects;
        _filterProjects();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Filter projects based on search query and assignment status
  /// Excludes projects that are already assigned to the intern
  /// Includes only projects that can accept more interns
  void _filterProjects() {
    _filteredProjects = _allProjects.where((project) {
      // Exclude already assigned projects
      if (widget.currentProjectIds.contains(project.id)) {
        return false;
      }
      
      // Exclude projects at capacity
      if (!project.canAcceptMoreInterns) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return project.name.toLowerCase().contains(query) ||
               project.description.toLowerCase().contains(query) ||
               project.requiredSkills.any((skill) => 
                 skill.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
    
    // Sort by priority (high priority first) then by name
    _filteredProjects.sort((a, b) {
      final priorityComparison = b.priorityLevel.compareTo(a.priorityLevel);
      if (priorityComparison != 0) return priorityComparison;
      return a.name.compareTo(b.name);
    });
  }

  /// Assign a project to the intern
  /// Shows loading state and success/error feedback
  Future<void> _assignProject(Project project) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Call API to assign the project
      final success = await _apiService.assignProjectToIntern(
        widget.internId, 
        project.id,
      );

      // Close loading dialog
      Get.back();

      if (success) {
        // Close assignment dialog and show success message
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Project "${project.name}" assigned to ${widget.internName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Info',
          'Project "${project.name}" is already assigned to ${widget.internName}',
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
        'Failed to assign project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog header with title and close button
            Row(
              children: [
                Icon(
                  Icons.assignment_add,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign Project',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'to ${widget.internName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Search bar for filtering projects
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects by name, description, or skills...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Project list or loading/error states
            Expanded(
              child: _buildProjectList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the main content area - project list, loading, or error state
  Widget _buildProjectList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading available projects...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProjects,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No projects found matching "$_searchQuery"'
                  : 'No available projects to assign',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'All projects are either assigned or at capacity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Display the filtered list of available projects
    return ListView.builder(
      itemCount: _filteredProjects.length,
      itemBuilder: (context, index) {
        final project = _filteredProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  /// Build a card for each available project
  /// Shows project details and assign button
  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project header with name and priority
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityChip(project.priority),
              ],
            ),
            
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Project metrics row
            Row(
              children: [
                _buildMetricChip(
                  icon: Icons.people,
                  label: '${project.currentInterns}/${project.maxInterns}',
                  color: project.isAtCapacity 
                      ? Colors.red 
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                if (project.hasDeadline)
                  _buildMetricChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(project.deadline!),
                    color: project.isOverdue 
                        ? Colors.red 
                        : Colors.blue,
                  ),
              ],
            ),
            
            // Required skills
            if (project.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.requiredSkills.take(3).map((skill) {
                  return Chip(
                    label: Text(
                      skill,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
              if (project.requiredSkills.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${project.requiredSkills.length - 3} more skills',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
            
            const SizedBox(height: 16),
            
            // Assign button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _assignProject(project),
                icon: const Icon(Icons.add),
                label: const Text('Assign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a priority indicator chip
  Widget _buildPriorityChip(String priority) {
    Color color;
    IconData icon;
    
    switch (priority.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'high':
        color = Colors.orange;
        icon = Icons.keyboard_arrow_up;
        break;
      case 'medium':
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color, width: 1),
    );
  }

  /// Build a metric indicator chip
  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference < 7) {
      return 'Due in $difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
