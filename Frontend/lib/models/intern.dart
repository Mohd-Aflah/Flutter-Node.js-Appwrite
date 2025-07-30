import 'task.dart';

/// Intern model representing an intern in the management system
class Intern {
  final String id;
  final String internName;
  final String batch;
  final List<String> roles;
  final List<String> currentProjects;
  final List<Task> tasksAssigned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Intern({
    required this.id,
    required this.internName,
    required this.batch,
    this.roles = const [],
    this.currentProjects = const [],
    this.tasksAssigned = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an Intern instance from JSON
  factory Intern.fromJson(Map<String, dynamic> json) {
    final tasksData = json['tasksAssigned'] as List? ?? [];
    final tasks = tasksData.map((taskData) {
      if (taskData is String) {
        try {
          final taskJson = Map<String, dynamic>.from(
            Uri.splitQueryString(taskData).map((key, value) => MapEntry(key, Uri.decodeComponent(value)))
          );
          return Task.fromJson(taskJson);
        } catch (e) {
          return Task.create(title: 'Invalid Task', status: 'open');
        }
      } else if (taskData is Map<String, dynamic>) {
        return Task.fromJson(taskData);
      } else {
        return Task.create(title: 'Unknown Task', status: 'open');
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

  /// Converts Intern instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internName': internName,
      'batch': batch,
      'roles': roles,
      'currentProjects': currentProjects,
      'tasksAssigned': tasksAssigned.map((task) => task.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of the intern with updated fields
  Intern copyWith({
    String? id,
    String? internName,
    String? batch,
    List<String>? roles,
    List<String>? currentProjects,
    List<Task>? tasksAssigned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Intern(
      id: id ?? this.id,
      internName: internName ?? this.internName,
      batch: batch ?? this.batch,
      roles: roles ?? this.roles,
      currentProjects: currentProjects ?? this.currentProjects,
      tasksAssigned: tasksAssigned ?? this.tasksAssigned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a new intern for creation (without server-generated fields)
  factory Intern.create({
    String? documentId,
    required String internName,
    required String batch,
    List<String> roles = const [],
    List<String> currentProjects = const [],
    List<Task> tasksAssigned = const [],
  }) {
    return Intern(
      id: documentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      internName: internName,
      batch: batch,
      roles: roles,
      currentProjects: currentProjects,
      tasksAssigned: tasksAssigned,
    );
  }

  /// Converts to JSON for API requests (excludes server-generated fields)
  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{
      'internName': internName,
      'batch': batch,
      'roles': roles,
      'currentProjects': currentProjects,
      'tasksAssigned': tasksAssigned.map((task) => task.toJson()).toList(),
    };
    
    // Include documentId if it's a custom ID
    if (id.isNotEmpty && !id.startsWith('auto_')) {
      json['documentId'] = id;
    }
    
    return json;
  }

  @override
  String toString() {
    return 'Intern(id: $id, name: $internName, batch: $batch, tasks: ${tasksAssigned.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Intern &&
        other.id == id &&
        other.internName == internName &&
        other.batch == batch;
  }

  @override
  int get hashCode {
    return Object.hash(id, internName, batch);
  }

  /// Get completed tasks count
  int get completedTasksCount {
    return tasksAssigned.where((task) => task.isCompleted).length;
  }

  /// Get pending tasks count
  int get pendingTasksCount {
    return tasksAssigned.where((task) => !task.isCompleted).length;
  }

  /// Get working tasks count
  int get workingTasksCount {
    return tasksAssigned.where((task) => task.isInProgress).length;
  }

  /// Get progress percentage
  double get progressPercentage {
    if (tasksAssigned.isEmpty) return 0.0;
    return (completedTasksCount / tasksAssigned.length) * 100;
  }

  /// Get roles as comma-separated string
  String get rolesString {
    return roles.join(', ');
  }

  /// Get projects as comma-separated string
  String get projectsString {
    return currentProjects.join(', ');
  }

  /// Check if intern has any tasks
  bool get hasTasks => tasksAssigned.isNotEmpty;

  /// Get task by status
  List<Task> getTasksByStatus(String status) {
    return tasksAssigned.where((task) => task.status == status).toList();
  }
}
