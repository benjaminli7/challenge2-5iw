import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/shared/services/group_service.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/mobile/views/groups/widgets/weather/weather_widget.dart';

class UserHikeHistory extends StatefulWidget {
  const UserHikeHistory({super.key});

  @override
  _UserHikeHistoryState createState() => _UserHikeHistoryState();
}

class _UserHikeHistoryState extends State<UserHikeHistory> {
  late Future<List<Group>> _groupsFuture;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupsFuture = _groupService.fetchMyGroups(user.token, user.id);
    } else {
      _groupsFuture = Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hikes History')),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups found'));
          } else {
            final currentDate = DateTime.now();
            final groups = snapshot.data!
                .where((group) => group.startDate.isBefore(currentDate))
                .toList();
            if (groups.isEmpty) {
              return const Center(child: Text('No Hikes history found'));
            } else {
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        Uri.parse("http://51.75.200.94:8080${group.hike.image}")
                            .toString(),
                      ),
                      radius: 30,
                    ),
                    title: Text(group.hike.name),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(group.startDate)),
                    onTap: () {
                      //for the moment just test the weather widget
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WeatherWidget(group: group),
                        ),
                      );
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
