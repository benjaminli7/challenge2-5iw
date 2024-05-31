import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/admin_provider.dart';
import 'package:frontend/models/user.dart';

class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: Consumer<AdminProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          return DataTable(
            columns: [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('IsVerify')),
            ],
            rows: userProvider.users
                .map(
                  (user) => DataRow(cells: [
                DataCell(Text(user.email)),
                DataCell(Text(user.role)),
                DataCell(Text(user.isVerified.toString())),
              ]),
            )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<AdminProvider>().fetchUsers(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
