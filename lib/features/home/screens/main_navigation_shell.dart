import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';
import '../../map/screens/live_map_screen.dart';
import '../../stats/screens/stats_analytics_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptics_service.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    HapticsService.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      const LiveMapScreen(),
      const StatsAnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.darkBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          selectedItemColor: AppTheme.primaryLight,
          unselectedItemColor: const Color(0xFF64748B),
          backgroundColor: AppTheme.darkSurface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Live Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}
