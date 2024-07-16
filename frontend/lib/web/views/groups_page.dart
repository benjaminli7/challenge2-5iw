import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:go_router/go_router.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        context.read<AdminProvider>().fetchGroups(user.token);
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select a date'
                      : 'Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.groups.isEmpty) {
                  return const Center(child: Text('No groups found'));
                }

                final filteredGroups = _selectedDate == null
                    ? adminProvider.groups
                    : adminProvider.groups.where((group) {
                  return DateFormat('dd/MM/yyyy')
                      .format(group.startDate) ==
                      DateFormat('dd/MM/yyyy')
                          .format(_selectedDate!);
                }).toList();

                if (filteredGroups.isEmpty) {
                  return const Center(child: Text('No groups found for selected date'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Date Start')),
                        DataColumn(label: Text('Hike')),
                        DataColumn(label: Text('Organizer')),
                      ],
                      rows: filteredGroups.map((group) {
                        return DataRow(cells: [
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                context.go('/group/${group.id}');
                              },
                              child: Text(
                                group.id.toString(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(DateFormat('dd/MM/yyyy').format(group.startDate))),
                          DataCell(Text(group.hike.name ?? 'None')),
                          DataCell(Text(group.organizer.email)),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = Provider.of<UserProvider>(context, listen: false).user;
          if (user != null) {
            context.read<AdminProvider>().fetchGroups(user.token);
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
