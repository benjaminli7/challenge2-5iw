import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
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
