import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../screens/admin_dashboard.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_reviews_screen.dart';
import '../screens/admin_movies_screen.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  const AdminSidebar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(AppConstants.surfaceColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.local_movies, color: Color(AppConstants.primaryColor), size: 28),
                const SizedBox(width: 8),
                const Text(
                  'MOVIETRACK',
                  style: TextStyle(
                    color: Color(AppConstants.primaryColor),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Admin Panel',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),

          const SizedBox(height: 30),

          _SidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => _navigate(context, 0),
          ),
          _SidebarItem(
            icon: Icons.people_rounded,
            label: 'Usuarios',
            isSelected: selectedIndex == 1,
            onTap: () => _navigate(context, 1),
          ),
          _SidebarItem(
            icon: Icons.rate_review_rounded,
            label: 'Reviews',
            isSelected: selectedIndex == 2,
            onTap: () => _navigate(context, 2),
          ),
          _SidebarItem(
            icon: Icons.movie_rounded,
            label: 'Contenido',
            isSelected: selectedIndex == 3,
            onTap: () => _navigate(context, 3),
          ),

          const Spacer(),

          const Divider(color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
              icon: const Icon(Icons.home_rounded, color: Colors.grey),
              label: const Text('Volver al inicio', style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;
    Widget page;
    switch (index) {
      case 0:
        page = const AdminDashboard();
        break;
      case 1:
        page = const AdminUsersScreen();
        break;
      case 2:
        page = const AdminReviewsScreen();
        break;
      case 3:
        page = const AdminMoviesScreen();
        break;
      default:
        page = const AdminDashboard();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? const Color(AppConstants.primaryColor).withOpacity(0.15)
        : _hovered
            ? Colors.white.withOpacity(0.05)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(color: const Color(AppConstants.primaryColor).withOpacity(0.4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? const Color(AppConstants.primaryColor)
                    : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.grey.shade400,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
              if (widget.isSelected) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(AppConstants.primaryColor),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
