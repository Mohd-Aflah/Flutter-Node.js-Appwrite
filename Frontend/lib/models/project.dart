/// Project model representing a project that can be assigned to interns
/// This model handles project data structure, serialization, and validation
/// Used throughout the application for project management and assignment features
class Project {
  /// Unique identifier for the project
  final String id;
  
  /// Display name of the project
  final String name;
  
  /// Detailed description of what the project involves
  final String description;
  
  /// Current status of the project (active, completed, on-hold, cancelled)
  final String status;
  
  /// Date when the project was created
  final DateTime createdAt;
  
  /// Date when the project was last updated
  final DateTime updatedAt;
  
  /// Optional deadline for project completion
  final DateTime? deadline;
  
  /// Priority level of the project (low, medium, high, critical)
  final String priority;
  
  /// List of technologies/skills required for this project
  final List<String> requiredSkills;
  
  /// Maximum number of interns that can be assigned to this project
  final int maxInterns;
  
  /// Current number of interns assigned to this project
  final int currentInterns;

  /// Constructor for creating a Project instance
  /// All required fields must be provided, optional fields have default values
  const Project({
    required this.id,
    required this.name,
    this.description = '',
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deadline,
    this.priority = 'medium',
    this.requiredSkills = const [],
    this.maxInterns = 5,
    this.currentInterns = 0,
  });

  /// Creates a Project instance from JSON data
  /// Used when receiving project data from the API or local storage
  /// Handles null safety and provides default values for missing fields
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      deadline: json['deadline'] != null 
          ? DateTime.tryParse(json['deadline'])
          : null,
      priority: json['priority'] ?? 'medium',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      maxInterns: json['maxInterns'] ?? 5,
      currentInterns: json['currentInterns'] ?? 0,
    );
  }

  /// Converts Project instance to JSON format
  /// Used when sending project data to the API or storing locally
  /// Ensures all fields are properly serialized
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'requiredSkills': requiredSkills,
      'maxInterns': maxInterns,
      'currentInterns': currentInterns,
    };
  }

  /// Creates a copy of the project with updated fields
  /// Useful for updating specific project properties while maintaining immutability
  /// Only specified fields will be updated, others remain unchanged
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadline,
    String? priority,
    List<String>? requiredSkills,
    int? maxInterns,
    int? currentInterns,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      maxInterns: maxInterns ?? this.maxInterns,
      currentInterns: currentInterns ?? this.currentInterns,
    );
  }

  /// Factory constructor for creating a new project with current timestamp
  /// Used when creating new projects, automatically sets creation and update times
  /// Generates a unique ID based on current timestamp if not provided
  factory Project.create({
    String? id,
    required String name,
    String description = '',
    String status = 'active',
    DateTime? deadline,
    String priority = 'medium',
    List<String> requiredSkills = const [],
    int maxInterns = 5,
  }) {
    final now = DateTime.now();
    return Project(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      status: status,
      createdAt: now,
      updatedAt: now,
      deadline: deadline,
      priority: priority,
      requiredSkills: requiredSkills,
      maxInterns: maxInterns,
      currentInterns: 0,
    );
  }

  /// Returns a string representation of the project
  /// Useful for debugging and logging purposes
  @override
  String toString() {
    return 'Project(id: $id, name: $name, status: $status, priority: $priority)';
  }

  /// Checks equality between two Project instances
  /// Projects are considered equal if all their properties match
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deadline == deadline &&
        other.priority == priority &&
        other.requiredSkills.length == requiredSkills.length &&
        other.maxInterns == maxInterns &&
        other.currentInterns == currentInterns;
  }

  /// Generates hash code for the project
  /// Used for efficient storage and comparison in collections
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      status,
      createdAt,
      updatedAt,
      deadline,
      priority,
      requiredSkills.length,
      maxInterns,
      currentInterns,
    );
  }

  // Convenience getters for checking project status
  
  /// Returns true if the project is currently active
  bool get isActive => status == 'active';
  
  /// Returns true if the project has been completed
  bool get isCompleted => status == 'completed';
  
  /// Returns true if the project is on hold
  bool get isOnHold => status == 'on-hold';
  
  /// Returns true if the project has been cancelled
  bool get isCancelled => status == 'cancelled';
  
  /// Returns true if the project has reached its maximum intern capacity
  bool get isAtCapacity => currentInterns >= maxInterns;
  
  /// Returns true if the project can accept more interns
  bool get canAcceptMoreInterns => currentInterns < maxInterns;
  
  /// Returns the number of available slots for interns
  int get availableSlots => maxInterns - currentInterns;
  
  /// Returns true if the project has a deadline set
  bool get hasDeadline => deadline != null;
  
  /// Returns true if the project deadline has passed (overdue)
  bool get isOverdue => hasDeadline && deadline!.isBefore(DateTime.now());
  
  /// Returns true if the project is high priority
  bool get isHighPriority => priority == 'high' || priority == 'critical';
  
  /// Returns the priority level as an integer for sorting (higher number = higher priority)
  int get priorityLevel {
    switch (priority.toLowerCase()) {
      case 'critical': return 4;
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 2; // Default to medium
    }
  }
}
