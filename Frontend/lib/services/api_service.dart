import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/intern.dart';
import '../models/task.dart';

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
      final queryParams = <String, String>{};

      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      if (order != null && order.isNotEmpty) queryParams['order'] = order;

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
        throw Exception(data['error'] ?? 'Failed to fetch interns');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
