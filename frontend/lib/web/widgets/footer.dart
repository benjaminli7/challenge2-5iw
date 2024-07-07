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
        GoRouter.of(context).go('/users');
        break;
      case 1:
        GoRouter.of(context).go('/groups');
        break;
      case 2:
        GoRouter.of(context).go('/hikes');
        break;
      case 3:
        GoRouter.of(context).go('/params');
        break;
        case 4:
          GoRouter.of(context).go('/home');
          break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Colors.white),
        label: 'User',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.group, color: Colors.white),
        label: 'Group',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.hiking, color: Colors.white),
        label: 'Hike',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.camera_outlined, color: Colors.white),
        label: 'Params',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home, color: Colors.white),
        label: 'Home',
      ),
    ];


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
