import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';
import 'about_screen.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

/// Main navigation container hosting bottom navigation and persistent bottom banner ad.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MapScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.speed_outlined),
                  selectedIcon: Icon(Icons.speed_rounded),
                  label: 'Gösterge',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: 'Harita',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Ayarlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.info_outline_rounded),
                  selectedIcon: Icon(Icons.info_rounded),
                  label: 'Hakkında',
                ),
              ],
            ),
            // Persistent bottom banner ad
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
