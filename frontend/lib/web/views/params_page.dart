import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/user.dart';

class ParamsPage extends StatefulWidget {
  const ParamsPage({super.key});

  @override
  _ParamsPageState createState() => _ParamsPageState();
}

class _ParamsPageState extends State<ParamsPage> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      // Fetch users when the page is first loaded
      context.read<AdminProvider>().fetchUsers(user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (adminProvider.users.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return DataTable(
            columns: [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
            ],
            rows: adminProvider.users.map((user) {
              return DataRow(cells: [
                DataCell(
                  GestureDetector(
                    onTap: () {
                      // Handle email click
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(user: user),
                        ),
                      );
                    },
                    child: Text(
                      user.email,
                      style: TextStyle(
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
        child: Icon(Icons.refresh),
      ),
    );
  }
}

// Sample UserDetailsPage to navigate to
class UserDetailsPage extends StatelessWidget {
  final User user;

  const UserDetailsPage({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
            Text('Role: ${user.role}', style: TextStyle(fontSize: 20)),
            Text('IsValide: ${user.isVerified.toString()}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context.read<AdminProvider>().deleteUser(token, user.id);

                  // After deletion, navigate back to the previous page
                  Navigator.of(context).pop();
                }
              },
              child: Text('Delete User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context.read<AdminProvider>().upgradeAdmin(token, user.id);

                  // After deletion, navigate back to the previous page
                  Navigator.of(context).pop();
                }
              },
              child: Text('Devenir Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}