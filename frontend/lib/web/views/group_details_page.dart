import 'package:flutter/material.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupDetailsPage extends StatelessWidget {
  final Group group;

  const GroupDetailsPage({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group ID: ${group.id.toString()}',
                style: const TextStyle(fontSize: 20)),
            Text(
                'Date Start: ${DateFormat('dd/MM/yyyy').format(group.startDate)}',
                style: const TextStyle(fontSize: 20)),
            Text('Hike: ${group.hike.name ?? 'None'}',
                style: const TextStyle(fontSize: 20)),
            Text('Organizer: ${group.organizer.email}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context
                      .read<AdminProvider>()
                      .deleteGroup(token, group.id);
                }
                if (context.mounted) {
                  context.go('/groups');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Group'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
