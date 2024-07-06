import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/models/hike.dart';

class HikeListPage extends StatefulWidget {
  const HikeListPage({super.key});

  @override
  _HikeListPageState createState() => _HikeListPageState();
}

class _HikeListPageState extends State<HikeListPage> {
  @override
  void initState() {
    super.initState();
    final hike = Provider.of<HikeProvider>(context, listen: false).hikes;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      // Fetch users when the page is first loaded
      context.read<AdminProvider>().fetchHikesNoValidate(user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hikes validation Panel')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (adminProvider.hikes.isEmpty) {
            return Center(child: Text('No hikes found'));
          }

          return DataTable(
            columns: [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Description')),
            ],
            rows: adminProvider.hikes.map((hike) {
              return DataRow(cells: [
                DataCell(
                  Image.network(
                    Uri.parse("http://192.168.1.110:8080${hike.image}")
                        .toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      // Handle email click
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HikeDetailsPage(hike: hike),
                        ),
                      );
                    },
                    child: Text(
                      hike.name,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(hike.description)),
              ]);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = Provider.of<UserProvider>(context, listen: false).user;
          if (user != null) {
            context.read<AdminProvider>().fetchHikesNoValidate(user.token);
          }
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class HikeDetailsPage extends StatelessWidget {
  final Hike hike;

  const HikeDetailsPage({required this.hike, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hike Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${hike.name}', style: TextStyle(fontSize: 20)),
            Text('Description: ${hike.description}',
                style: TextStyle(fontSize: 20)),
            Text('Difficulty: ${hike.difficulty}',
                style: TextStyle(fontSize: 20)),
            Text('Duration: ${hike.duration}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context
                      .read<AdminProvider>()
                      .validateHike(token, hike.id);

                  // After deletion, navigate back to the previous page
                  Navigator.of(context).pop();
                }
              },
              child: Text('Valider'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
