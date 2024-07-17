import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserManagement extends StatelessWidget {
  final User user;

  const UserManagement({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(AppLocalizations.of(context)!.userDetail)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.userEmail(user.email), style: const TextStyle(fontSize: 20)),
            Text(AppLocalizations.of(context)!.userRole(user.role), style: const TextStyle(fontSize: 20)),
            Text(AppLocalizations.of(context)!.userIsValide(user.isVerified.toString()),
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
                      .deleteUser(token, user.id);

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:  Text(AppLocalizations.of(context)!.deleteUser),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  final token = userProvider.user!.token;
                  await context
                      .read<AdminProvider>()
                      .upgradeAdmin(token, user.id);

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(AppLocalizations.of(context)!.upgradeAdmin),
            ),
          ],
        ),
      ),
    );
  }
}
