import 'package:flutter/material.dart';
import '../widgets/sidebar_navigation.dart';
import '../screens/home_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/tasks_screen.dart';

/// Main dashboard layout with sidebar navigation
class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout>
    with TickerProviderStateMixin {
  String _currentRoute = '/home';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case '/home':
        return const HomeScreen();
      case '/projects':
        return const ProjectsScreen();
      case '/tasks':
        return const TasksScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    
    if (isMobile) {
      // Mobile layout with drawer
      return Scaffold(
        backgroundColor: Colors.grey[50],
        drawer: Drawer(
          child: SidebarNavigation(
            currentRoute: _currentRoute,
            onNavigate: (route) {
              _navigateToRoute(route);
              Navigator.of(context).pop(); // Close drawer
            },
          ),
        ),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                child: _getCurrentScreen(),
              ),
            );
          },
        ),
      );
    } else {
      // Desktop layout with persistent sidebar
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Row(
          children: [
            // Sidebar Navigation
            SidebarNavigation(
              currentRoute: _currentRoute,
              onNavigate: _navigateToRoute,
            ),
            
            // Main Content
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: _getCurrentScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
