import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/shared/models/group.dart';

class GroupList extends StatelessWidget {
  final List<Group> groups;

  const GroupList({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(

          title: Text(group.organizer.email),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(group.startDate)),
        );
      },
    );
  }
}
