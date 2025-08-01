import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../models/project.dart';

/// API service for handling HTTP requests to the Intern Management backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  /// Get headers for HTTP requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Handle HTTP response and extract data
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      try {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'HTTP ${response.statusCode}');
      } catch (e) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    }
  }

  /// Get all interns with optional query parameters
  Future<List<Intern>> getAllInterns({
    String? batch,
    String? search,
    int? limit,
    int? offset,
    String? sort,
    String? order,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internsEndpoint}');
      
      // Temporarily disable query parameters due to Appwrite function issue
      // TODO: Re-enable once Appwrite function handles query parameters properly
      final queryParams = <String, String>{};

      // Only add search and batch filters for now (these are more critical)
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      // Skip pagination and sorting parameters that cause "Syntax error"
      // if (limit != null) queryParams['limit'] = limit.toString();
      // if (offset != null) queryParams['offset'] = offset.toString();
      // if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      // if (order != null && order.isNotEmpty) queryParams['order'] = order;

      final finalUri = queryParams.isEmpty
          ? uri
          : uri.replace(queryParameters: queryParams);

      final response = await _client
          .get(finalUri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] is List) {
        final internsData = data['data'] as List;
        return internsData.map((json) => _parseInternJson(json)).toList();
      } else {
        throw Exception(data['error'] ?? 'Unable to load interns');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to connect to server. Please try again later.');
    }
  }

  /// Get a specific intern by ID
  Future<Intern> getIntern(String internId) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internsEndpoint}/$internId');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        return _parseInternJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch intern');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new intern
  Future<Intern> createIntern(Intern intern) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internsEndpoint}');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: json.encode(intern.toCreateJson()),
          )
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        return _parseInternJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to create intern');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update an existing intern
  Future<Intern> updateIntern(String internId, Intern intern) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internsEndpoint}/$internId');

      // For updates, we don't include the documentId
      final updateData = intern.toCreateJson();
      updateData.remove('documentId');

      final response = await _client
          .patch(
            uri,
            headers: _headers,
            body: json.encode(updateData),
          )
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        return _parseInternJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to update intern');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete an intern
  Future<void> deleteIntern(String internId) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internsEndpoint}/$internId');

      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to delete intern');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get total intern count
  Future<int> getInternCount() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.internCountEndpoint}');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['count'] != null) {
        return data['count'] as int;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch intern count');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get task summary across all interns
  Future<Map<String, int>> getTaskSummary() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.taskSummaryEndpoint}');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      if (data['success'] == true && data['summary'] != null) {
        final summary = data['summary'] as Map<String, dynamic>;
        return summary.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch task summary');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Parse intern JSON with proper task handling
  Intern _parseInternJson(Map<String, dynamic> json) {
    // Handle tasks parsing - they might be strings or objects
    final tasksData = json['tasksAssigned'] as List? ?? [];
    final tasks = tasksData.map((taskData) {
      if (taskData is String) {
        // Parse JSON string
        try {
          final taskJson = jsonDecode(taskData) as Map<String, dynamic>;
          return _parseTaskJson(taskJson);
        } catch (e) {
          // If parsing fails, create a minimal task
          return Task.create(
            title: 'Invalid Task',
            status: 'open',
            description: 'Failed to parse task data',
          );
        }
      } else if (taskData is Map<String, dynamic>) {
        return _parseTaskJson(taskData);
      } else {
        return Task.create(
          title: 'Unknown Task',
          status: 'open',
          description: 'Unknown task format',
        );
      }
    }).toList();

    return Intern(
      id: json['\$id'] ?? json['id'] ?? '',
      internName: json['internName'] ?? '',
      batch: json['batch'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      currentProjects: List<String>.from(json['currentProjects'] ?? []),
      tasksAssigned: tasks,
      createdAt: json['\$createdAt'] != null 
          ? DateTime.tryParse(json['\$createdAt'])
          : null,
      updatedAt: json['\$updatedAt'] != null 
          ? DateTime.tryParse(json['\$updatedAt'])
          : null,
    );
  }

  /// Parse task JSON
  Task _parseTaskJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      assignedAt: json['assignedAt'] != null 
          ? DateTime.tryParse(json['assignedAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // PROJECT MANAGEMENT METHODS

  /// Get all projects with optional filtering
  /// TEMPORARY WORKAROUND: Extract projects from intern records since
  /// the backend doesn't have dedicated project endpoints
  Future<List<Project>> getAllProjects({
    String? status,
    String? priority,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      // Get all interns to extract project information
      final interns = await getAllInterns();
      
      // Extract unique projects from intern records
      final Map<String, Project> projectsMap = {};
      
      for (final intern in interns) {
        for (final projectName in intern.currentProjects) {
          if (projectName.isNotEmpty && !projectsMap.containsKey(projectName)) {
            // Create a mock project based on the project name
            final project = Project(
              id: projectName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), ''),
              name: projectName,
              description: 'Project: $projectName',
              status: 'active', // Default status
              priority: 'medium', // Default priority
              deadline: DateTime.now().add(const Duration(days: 60)),
              currentInterns: interns
                  .where((i) => i.currentProjects.contains(projectName))
                  .length,
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              updatedAt: DateTime.now(),
            );
            projectsMap[projectName] = project;
          }
        }
      }
      
      List<Project> projects = projectsMap.values.toList();
      
      // Apply filters
      if (search != null && search.isNotEmpty) {
        projects = projects.where((p) => 
          p.name.toLowerCase().contains(search.toLowerCase()) ||
          p.description.toLowerCase().contains(search.toLowerCase())
        ).toList();
      }
      
      if (status != null && status.isNotEmpty) {
        projects = projects.where((p) => p.status == status).toList();
      }
      
      if (priority != null && priority.isNotEmpty) {
        projects = projects.where((p) => p.priority == priority).toList();
      }
      
      // Apply pagination
      if (offset != null && offset > 0) {
        projects = projects.skip(offset).toList();
      }
      
      if (limit != null && limit > 0) {
        projects = projects.take(limit).toList();
      }
      
      return projects;
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  /// Get a specific project by ID
  /// TEMPORARY WORKAROUND: Extract project from intern records
  Future<Project> getProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      final project = projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      return project;
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  /// Create a new project
  /// TEMPORARY WORKAROUND: Projects are managed through intern assignments
  /// This is a placeholder until backend project endpoints are implemented
  Future<Project> createProject(Project project) async {
    try {
      // Since projects are managed through intern assignments,
      // we'll just return the project as-is for now
      // In a real implementation, you'd want to store this in a separate collection
      return project.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Update an existing project
  /// TEMPORARY WORKAROUND: Projects are managed through intern assignments
  Future<Project> updateProject(String projectId, Project project) async {
    try {
      // Since projects are managed through intern assignments,
      // we'll just return the updated project as-is for now
      return project.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete a project
  /// Removes the project from the backend permanently
  Future<bool> deleteProject(String projectId) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.projectsEndpoint}/$projectId');

      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(AppConfig.connectTimeout);

      final data = _handleResponse(response);

      return data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Assign a project to an intern
  /// Updates the intern's currentProjects list to include the new project
  Future<bool> assignProjectToIntern(String internId, String projectId) async {
    try {
      // First get the current intern data
      final intern = await getIntern(internId);
      
      // Add the project to their current projects if not already assigned
      final updatedProjects = List<String>.from(intern.currentProjects);
      if (!updatedProjects.contains(projectId)) {
        updatedProjects.add(projectId);
        
        // Update the intern with the new project list
        final updatedIntern = intern.copyWith(currentProjects: updatedProjects);
        await updateIntern(internId, updatedIntern);
        return true;
      }
      
      return false; // Project already assigned
    } catch (e) {
      throw Exception('Failed to assign project to intern: $e');
    }
  }

  /// Unassign a project from an intern
  /// Removes the project from the intern's currentProjects list
  Future<bool> unassignProjectFromIntern(String internId, String projectId) async {
    try {
      // First get the current intern data
      final intern = await getIntern(internId);
      
      // Remove the project from their current projects
      final updatedProjects = List<String>.from(intern.currentProjects);
      if (updatedProjects.remove(projectId)) {
        // Update the intern with the new project list
        final updatedIntern = intern.copyWith(currentProjects: updatedProjects);
        await updateIntern(internId, updatedIntern);
        return true;
      }
      
      return false; // Project was not assigned
    } catch (e) {
      throw Exception('Failed to unassign project from intern: $e');
    }
  }

  /// Add a task to an intern
  /// Updates the intern's tasksAssigned list to include the new task
  Future<bool> addTaskToIntern(String internId, Task task) async {
    try {
      // First get the current intern data
      final intern = await getIntern(internId);
      
      // Add the task to their assigned tasks
      final updatedTasks = List<Task>.from(intern.tasksAssigned);
      updatedTasks.add(task);
      
      // Update the intern with the new task list
      final updatedIntern = intern.copyWith(tasksAssigned: updatedTasks);
      await updateIntern(internId, updatedIntern);
      
      return true;
    } catch (e) {
      throw Exception('Failed to add task to intern: $e');
    }
  }

  /// Update a task for an intern
  /// Finds and updates a specific task in the intern's tasksAssigned list
  Future<bool> updateTaskForIntern(String internId, Task updatedTask) async {
    try {
      // First get the current intern data
      final intern = await getIntern(internId);
      
      // Find and update the task
      final updatedTasks = List<Task>.from(intern.tasksAssigned);
      final taskIndex = updatedTasks.indexWhere((task) => task.id == updatedTask.id);
      
      if (taskIndex != -1) {
        updatedTasks[taskIndex] = updatedTask;
        
        // Update the intern with the modified task list
        final updatedIntern = intern.copyWith(tasksAssigned: updatedTasks);
        await updateIntern(internId, updatedIntern);
        
        return true;
      }
      
      return false; // Task not found
    } catch (e) {
      throw Exception('Failed to update task for intern: $e');
    }
  }

  /// Remove a task from an intern
  /// Removes a specific task from the intern's tasksAssigned list
  Future<bool> removeTaskFromIntern(String internId, String taskId) async {
    try {
      // First get the current intern data
      final intern = await getIntern(internId);
      
      // Remove the task from their assigned tasks
      final updatedTasks = List<Task>.from(intern.tasksAssigned);
      final initialLength = updatedTasks.length;
      updatedTasks.removeWhere((task) => task.id == taskId);
      final taskRemoved = updatedTasks.length < initialLength;
      
      if (taskRemoved) {
        // Update the intern with the new task list
        final updatedIntern = intern.copyWith(tasksAssigned: updatedTasks);
        await updateIntern(internId, updatedIntern);
        
        return true;
      }
      
      return false; // Task not found
    } catch (e) {
      throw Exception('Failed to remove task from intern: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
