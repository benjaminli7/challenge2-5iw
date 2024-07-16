import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      context.read<AdminProvider>().fetchUsers(user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
            ],
            rows: adminProvider.users.map((user) {
              return DataRow(cells: [
                DataCell(
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context)
                          .go('/admin/user/management/${user.id}');
                    },
                    child: Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(user.role)),
              ]);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = Provider.of<UserProvider>(context, listen: false).user;
          if (user != null) {
            context.read<AdminProvider>().fetchUsers(user.token);
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
