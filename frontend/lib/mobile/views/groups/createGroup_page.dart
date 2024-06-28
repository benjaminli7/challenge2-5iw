import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/mobile/views/groups/widgets/hike_details_section.dart';
import 'package:frontend/mobile/views/groups/widgets/difficulty_group_section.dart';
import 'package:frontend/mobile/views/groups/widgets/select_hike_date_section.dart';
import 'package:frontend/mobile/views/groups/widgets/select_start_time_section.dart';
import 'package:frontend/mobile/views/groups/widgets/type_group_section.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart'; // Importer le service

class CreateGroupPage extends StatelessWidget {
  final Hike hike;
  const CreateGroupPage({Key? key, required this.hike}) : super(key: key);

  void _validateAndSend(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupData = groupProvider.collectGroupData();

    final groupService = GroupService();

    try {
      // Envoyer les données au backend
      final response = await groupService.createGroup(groupData, hike.id, userProvider.user!.id, userProvider.user!.token);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
        Navigator.of(context).pop();
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
        title: const Text('Create Group'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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

              const TypeGroupSection(),
              const SizedBox(height: 20),

              const DifficultyGroupSection(),
              const SizedBox(height: 20),

              const SelectHikeDateSection(),
              const SizedBox(height: 20),

              const SelectStartTimeSection(),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () => _validateAndSend(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Validate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
