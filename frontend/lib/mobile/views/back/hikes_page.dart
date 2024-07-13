import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

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
                    Uri.parse("${dotenv.env['BASE_URL']}${hike.image}")
                        .toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context)
                          .go('/admin/hike/management/${hike.id}');
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
