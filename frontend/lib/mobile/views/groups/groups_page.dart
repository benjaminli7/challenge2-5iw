import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/shared/services/group_service.dart'; // Assurez-vous de pointer vers le bon fichier
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<Group>> _groupsFuture;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupsFuture = _groupService.fetchMyGroups(user.token, user.id);
    } else {
      _groupsFuture = Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groups')),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups found'));
          } else {
            final groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.id.toString()),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(group.dateStart)),
                  onTap: () {
                    // Gérer la navigation vers les détails du groupe
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
