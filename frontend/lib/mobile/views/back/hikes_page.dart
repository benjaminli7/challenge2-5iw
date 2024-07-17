import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../shared/services/config_service.dart';


class HikeListPage extends StatefulWidget {
  const HikeListPage({super.key});

  @override
  _HikeListPageState createState() => _HikeListPageState();
}

class _HikeListPageState extends State<HikeListPage> {
  String baseUrl = ConfigService.baseUrl;

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.hikeValidationPannel)),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.hikes.isEmpty) {
            return  Center(child: Text(AppLocalizations.of(context)!.noHikesFound));
          }

          return DataTable(
            columns:  [
              DataColumn(label: Text(AppLocalizations.of(context)!.image)),
              DataColumn(label: Text(AppLocalizations.of(context)!.name)),
              DataColumn(label: Text(AppLocalizations.of(context)!.description)),
            ],
            rows: adminProvider.hikes.map((hike) {
              return DataRow(cells: [
                DataCell(
                  Image.network(

                    Uri.parse("$baseUrl${hike.image}").toString(),
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

