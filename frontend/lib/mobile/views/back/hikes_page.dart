import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
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
      context.read<AdminProvider>().fetchHikesNoValidate(user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hikes validation Panel')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.hikes.isEmpty) {
            return const Center(child: Text('No hikes found'));
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Description')),
            ],
            rows: adminProvider.hikes.map((hike) {
              return DataRow(cells: [
                DataCell(
                  Image.network(

                    Uri.parse("http://10.0.2.2:8080${hike.image}").toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HikeDetailsPage(hike: hike),
                        ),
                      );
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
        child: const Icon(Icons.refresh),
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
      appBar: AppBar(title: const Text('Hike Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${hike.name}', style: const TextStyle(fontSize: 20)),
            Text('Description: ${hike.description}',
                style: const TextStyle(fontSize: 20)),
            Text('Difficulty: ${hike.difficulty}',
                style: const TextStyle(fontSize: 20)),
            Text('Duration: ${hike.duration}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context
                      .read<AdminProvider>()
                      .validateHike(token, hike.id);

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
