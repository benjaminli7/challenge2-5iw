import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:go_router/go_router.dart';
class UsersDetailsPage extends StatelessWidget {
  final User user;

  const UsersDetailsPage({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}', style: const TextStyle(fontSize: 20)),
            Text('Role: ${user.role}', style: const TextStyle(fontSize: 20)),
            Text('IsValide: ${user.isVerified.toString()}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context.read<AdminProvider>().deleteUser(token, user.id);

                  if (context.mounted) {
                    context.go('/users');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context.read<AdminProvider>().upgradeAdmin(token, user.id);

                  context.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Devenir Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
