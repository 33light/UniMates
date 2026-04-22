import 'package:flutter/material.dart';
import 'package:unimates/screens/community/community_feed.dart';
import 'package:unimates/screens/marketplace_screen.dart';
import 'package:unimates/screens/messaging_screen.dart';
import 'package:unimates/screens/lost_found_screen.dart';
import 'package:unimates/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  // Simple list — HomeScreen itself is kept alive by _AuthGate in main.dart,
  // so this list is created once and never recreated on auth state emissions.
  // Each screen is (re)mounted on first tap; the service-layer cache in
  // MockApiService ensures instant display on remount without a spinner.
  final List<Widget> _screens = [
    const CommunityFeedScreen(),
    const MarketplaceScreen(),
    const MessagingScreen(),
    const LostFoundScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Lost & Found',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
