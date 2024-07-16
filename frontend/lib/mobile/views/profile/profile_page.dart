import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import go_router.dart;
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Profile of ${user?.email}! ',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 32),
            // First block with Profile and Trail Pass buttons
            buildMenuBlock([
              buildMenuItem(Icons.person, 'Profile', () {
                GoRouter.of(context).go('/profile/details');
              }),
            ]),
            buildMenuBlock([
              buildMenuItem(Icons.directions_walk, 'Trail pass', () {
                GoRouter.of(context).go('/profile/hike-history');
              }),
            ]),
            const SizedBox(height: 16),
            // Second block with Filters, Security, Alerts, Theme, Advanced buttons
            buildMenuBlock([
              buildMenuItem(Icons.filter_list, 'Filters', () {}),
              buildMenuItem(Icons.security, 'Security', () {
                // Handle Security tap
              }),
              buildMenuItem(Icons.notifications, 'Alerts', () {
                // Handle Alerts tap
              }),
              buildMenuItem(Icons.color_lens, 'Theme', () {
                // Handle Theme tap
              }),
              buildMenuItem(Icons.settings, 'Advanced', () {
                // Handle Advanced tap
              }),
            ]),
            const SizedBox(height: 16),
            // Third block with Support and Sign Out buttons
            buildMenuBlock([
              buildMenuItem(Icons.support, 'Support', () {
                // Handle Support tap
              }),
              buildMenuItem(Icons.logout, 'Sign out', () {
                // Handle Sign Out tap
                // Clear the user from the provider
                Provider.of<UserProvider>(context, listen: false).clearUser();
                // Show a toast message
                Fluttertoast.showToast(
                  msg: "Disconnected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                );
                // Navigate to the login page
                GoRouter.of(context).go('/login');
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildMenuBlock(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((entry) => Column(
                  children: [
                    entry.value,
                    if (entry.key != items.length - 1)
                      Divider(height: 1, color: Colors.grey[700]),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
