import 'package:flutter/material.dart';

/// Sidebar navigation widget for the dashboard
class SidebarNavigation extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInDrawer = MediaQuery.of(context).size.width < 768;
    
    return Container(
      width: isInDrawer ? null : 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: isInDrawer ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Intern Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    route: '/home',
                    isActive: currentRoute == '/home',
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    context,
                    icon: Icons.folder_rounded,
                    label: 'Projects',
                    route: '/projects',
                    isActive: currentRoute == '/projects',
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    context,
                    icon: Icons.task_rounded,
                    label: 'Tasks',
                    route: '/tasks',
                    isActive: currentRoute == '/tasks',
                  ),
                ],
              ),
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Administrator',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigate(route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive 
                  ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
