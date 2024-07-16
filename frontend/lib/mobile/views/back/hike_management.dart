import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HikeManagement extends StatelessWidget {
  final Hike hike;

  const HikeManagement({required this.hike, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.hikeDetails)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.hikeName(hike.name), style: const TextStyle(fontSize: 20)),
            Text(AppLocalizations.of(context)!.hikeDescription(hike.description),
                style: const TextStyle(fontSize: 20)),
            Text(AppLocalizations.of(context)!.hikeDifficulty(hike.difficulty),
                style: const TextStyle(fontSize: 20)),
            Text(AppLocalizations.of(context)!.hikeDuration(hike.duration.toString()),
                style: const TextStyle(fontSize: 20)),
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
              child: Text(AppLocalizations.of(context)!.hikeValidation),
            ),
          ],
        ),
      ),
    );
  }
}
