/// Task model representing a task assigned to an intern
class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime assignedAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.status,
    required this.assignedAt,
    required this.updatedAt,
  });

  /// Creates a Task instance from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
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

  /// Converts Task instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'assignedAt': assignedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? assignedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a new task with current timestamp
  factory Task.create({
    String? id,
    required String title,
    String description = '',
    required String status,
  }) {
    final now = DateTime.now();
    return Task(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: status,
      assignedAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.assignedAt == assignedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      status,
      assignedAt,
      updatedAt,
    );
  }

  /// Check if task is completed
  bool get isCompleted => status == 'completed';
  
  /// Check if task is in progress
  bool get isInProgress => status == 'working';
  
  /// Check if task is open
  bool get isOpen => status == 'open';
  
  /// Check if task is pending
  bool get isPending => status == 'pending';
  
  /// Check if task is deferred
  bool get isDeferred => status == 'deferred';
  
  /// Check if task is todo
  bool get isTodo => status == 'todo';
}
