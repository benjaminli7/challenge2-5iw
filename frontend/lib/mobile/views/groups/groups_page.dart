import 'package:flutter/material.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final groupsProvider = Provider.of<GroupProvider>(context);

    final groupsCreatedByUser = groupsProvider.groups.where(
      (group) => group.organizerId == user!.id,
    );

    final groupsJoinedByUser = groupsProvider.groups.where(
      (group) => group.members.contains(user!.id),
    );

    print(groupsCreatedByUser);
    print(groupsJoinedByUser);

    // get groups where organizer_id = user.id
    return const Scaffold(
      body: Center(
        child: Text(
          'Groups',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
