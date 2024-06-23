import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        GoRouter.of(context).go('/explore');
        break;
      case 1:
        GoRouter.of(context).go('/groups');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
      case 3:
        GoRouter.of(context).go('/admin');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.explore, color: Colors.white),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group, color: Colors.white),
        label: 'Groups',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Colors.white),
        label: 'Profile',
      ),
    ];

    if (user != null && user.role == 'admin') {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings, color: Colors.white),
          label: 'Admin',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: items,
      backgroundColor: const Color(0xFF1b1b1b), // Background color
      selectedItemColor: Colors.white, // Selected icon and text color
      unselectedItemColor: Colors.white, // Unselected icon and text color
      selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white), // Selected text bold
      unselectedLabelStyle:
      const TextStyle(color: Colors.white), // Unselected text color
    );
  }
}
