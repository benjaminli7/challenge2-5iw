import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/mobile/views/groups/widgets/hike_details_section.dart';
import 'package:frontend/mobile/views/groups/widgets/select_hike_date_section.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateGroupPage extends StatelessWidget {
  final Hike hike;
  const CreateGroupPage({super.key, required this.hike});

  void _validateAndSend(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupData = groupProvider.collectGroupData();

    final groupService = GroupService();

    try {
      if (groupData['name'] == null || groupData['name'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.groupNameRequire)),
        );
        return;
      }
      final response = await groupService.createGroup(
          groupData, hike.id, userProvider.user!.id, userProvider.user!.token);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.groupCreated)),
        );
        GoRouter.of(context).go('/groups');

        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createGroup),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/hike/${hike.id}');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HikeDetailsSection(hike: hike),
              const SizedBox(height: 20),
              TextField(
                decoration:  InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupName,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  Provider.of<GroupProvider>(context, listen: false)
                      .setGroupName(value);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration:  InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupDescription,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  Provider.of<GroupProvider>(context, listen: false)
                      .setGroupDescription(value);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.maxParticipants,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  Provider.of<GroupProvider>(context, listen: false)
                      .setMaxUsers(int.parse(value));
                },
              ),
              const SizedBox(height: 20),
              const SelectHikeDateSection(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _validateAndSend(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: Text(AppLocalizations.of(context)!.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
