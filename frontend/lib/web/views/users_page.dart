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

          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(maxWidth: 800),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('IsVerified')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Supprimer')),
                ],
                rows: adminProvider.users.map((user) {
                  return DataRow(cells: [
                    DataCell(Text(user.email)),
                    DataCell(Text(user.isVerified.toString())),
                    DataCell(Text(user.role)),
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          context.go('/user/${user.id}');
                        },
                        child: const Text(
                          "Voir les details",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
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
