import 'package:flutter/material.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/mobile/views/groups/widgets/weather/weather_widget.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _groupService = GroupService();
  late Future<Group> _groupFuture;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupFuture = _groupService.getGroupById(user.token, widget.groupId);
    } else {
      _groupFuture = Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Group Detail'),
        ),
        body: FutureBuilder<Group>(
          future: _groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No group found'));
            } else {
              final group = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      'Name: ${group.hike.name}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Description: ${group.description}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Start Date: ${group.startDate}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Organizer: ${group.organizer.username}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat, size: 16.0),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        GoRouter.of(context).push('/group-chat/${group.id}');
                      },
                      label: const Text('Group Chat'),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: WeatherWidget(
                        group: group,
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ));
  }
}
