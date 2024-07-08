import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import go_router.dart;
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/providers/user_provider.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
                'Profile of ${user?.email}!',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 32),

            buildMenuBlock([
              buildMenuItem(Icons.person, 'Users', () {
                GoRouter.of(context).go('/admin/users');
              }),
              buildMenuItem(Icons.hiking, 'Hike', () {
                GoRouter.of(context).go('/admin/hikes');
              }),
              buildMenuItem(Icons.settings, 'Settings', () {
                GoRouter.of(context).go('/admin/settings');
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
