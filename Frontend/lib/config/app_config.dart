/// Configuration class for API endpoints and app settings
class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://688a1c420012de357297.fra.appwrite.run';
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String internsEndpoint = '/interns';
  static const String internCountEndpoint = '/interns/count';
  static const String taskSummaryEndpoint = '/interns/tasks/summary';
  static const String projectsEndpoint = '/projects';
  static const String projectCountEndpoint = '/projects/count';
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // App Configuration
  static const String appName = 'Intern Management System';
  static const String appVersion = '1.0.0';
  
  // UI Configuration
  static const int itemsPerPage = 10;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Task Statuses
  static const List<String> taskStatuses = [
    'open',
    'completed', 
    'todo',
    'working',
    'deferred',
    'pending'
  ];
  
  // Task Status Colors
  static const Map<String, String> taskStatusColors = {
    'open': '#2196F3',      // Blue
    'completed': '#4CAF50',  // Green
    'todo': '#FF9800',       // Orange
    'working': '#9C27B0',    // Purple
    'deferred': '#795548',   // Brown
    'pending': '#607D8B',    // Blue Grey
  };

  // Available Roles for Interns
  static const List<String> availableRoles = [
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Mobile Developer',
    'DevOps Engineer',
    'UI/UX Designer',
    'QA Engineer',
    'Data Scientist',
    'Machine Learning Engineer',
    'Project Manager',
    'Team Lead',
    'Senior Frontend Developer',
    'Senior Backend Developer',
    'Technical Lead',
    'Software Architect',
  ];

  // Validation Rules
  static const int maxInternNameLength = 50;
  static const int maxBatchLength = 20;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;  // Environment specific configurations
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDebug => !isProduction;
}
