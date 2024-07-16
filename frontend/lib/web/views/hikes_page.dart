import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';

class HikesPage extends StatefulWidget {
  const HikesPage({super.key});

  @override
  _HikesPageState createState() => _HikesPageState();
}

class _HikesPageState extends State<HikesPage> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      context.read<HikeProvider>().fetchHikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hikes List')),
      body: Consumer<HikeProvider>(
        builder: (context, hikeProvider, child) {
          if (hikeProvider.hikes.isEmpty) {
            return const Center(child: Text('No hikes found'));
          }

          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(maxWidth: 800),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Duration')),
                  DataColumn(label: Text('Difficulty')),
                  DataColumn(label: Text('IsApproved')),
                ],
                rows: hikeProvider.hikes.map((hike) {
                  return DataRow(cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          context.go('/hike/${hike.id}');
                        },
                        child: Text(
                          hike.name,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(hike.description)),
                    DataCell(Text(hike.duration.toString())),
                    DataCell(Text(hike.difficulty)),
                    DataCell(Text(hike.isApproved.toString())),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
