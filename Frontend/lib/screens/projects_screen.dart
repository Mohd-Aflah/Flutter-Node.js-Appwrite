import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intern_controller.dart';
import '../models/intern.dart';

/// Projects screen showing all projects and assigned interns
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

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
                    'Projects Overview',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View all projects and their assigned interns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProjectDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Project'),
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

          // Project Statistics
          Obx(() => _buildProjectStats(controller)),
          const SizedBox(height: 32),

          // Projects List
          Expanded(
            child: Obx(() => _buildProjectsList(context, controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStats(InternController controller) {
    final projects = _getAllProjects(controller.interns);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Projects',
            '${projects.length}',
            Icons.folder_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Projects',
            '${projects.where((p) => p['interns'].isNotEmpty).length}',
            Icons.folder_open_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Assignments',
            '${projects.fold<int>(0, (sum, p) => sum + (p['interns'] as List).length)}',
            Icons.assignment_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Average Team Size',
            projects.isEmpty 
                ? '0'
                : (projects.fold<int>(0, (sum, p) => sum + (p['interns'] as List).length) / projects.length).toStringAsFixed(1),
            Icons.group_rounded,
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

  Widget _buildProjectsList(BuildContext context, InternController controller) {
    final projects = _getAllProjects(controller.interns);

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Projects will appear here when interns are assigned to them'),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, project);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Map<String, dynamic> project) {
    final projectName = project['name'] as String;
    final interns = project['interns'] as List<Intern>;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showProjectDetails(context, project),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded),
                              SizedBox(width: 8),
                              Text('Edit Project'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Project', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  projectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${interns.length} intern${interns.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (interns.isNotEmpty) ...[
                  const Text(
                    'Team Members:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: interns.take(3).map((intern) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          intern.internName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                  if (interns.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${interns.length - 3} more',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No interns assigned',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllProjects(List<Intern> interns) {
    final Map<String, List<Intern>> projectMap = {};

    for (final intern in interns) {
      for (final project in intern.currentProjects) {
        if (!projectMap.containsKey(project)) {
          projectMap[project] = [];
        }
        projectMap[project]!.add(intern);
      }
    }

    return projectMap.entries.map((entry) => {
      'name': entry.key,
      'interns': entry.value,
    }).toList()..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  void _showAddProjectDialog(BuildContext context) {
    // TODO: Implement add project dialog
    Get.snackbar(
      'Coming Soon',
      'Add project feature will be implemented soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showProjectDetails(BuildContext context, Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder_rounded,
                    color: Colors.orange[700],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Assigned Interns (${(project['interns'] as List).length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if ((project['interns'] as List).isEmpty)
                const Text('No interns assigned to this project')
              else
                ...((project['interns'] as List<Intern>).map((intern) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                intern.internName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Batch: ${intern.batch}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (intern.roles.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              intern.roles.first,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
