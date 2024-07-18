import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../shared/services/config_service.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String baseUrl = ConfigService.baseUrl;
  late Future<List<Group>> _groupsFuture;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupsFuture = _groupService.fetchMyGroups(user.token, user.id);
    } else {
      _groupsFuture = Future.error(AppLocalizations.of(context)!.userNotLogged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text(AppLocalizations.of(context)!.groups)
      ,centerTitle: true,
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text(AppLocalizations.of(context)!.noGroupFound));
          } else {
            final groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      Uri.parse("$baseUrl${group.hike.image}").toString(),
                    ),
                    radius: 30,
                  ),
                  title: Text(group.name),
                  subtitle: Text(
                      "${group.hike.name} \n${DateFormat('yyyy-MM-dd').format(group.startDate)}"),
                  trailing:
                      group.organizer.id ==
                              Provider.of<UserProvider>(context, listen: false)
                                  .user!
                                  .id
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                try {
                                  _groupService
                                      .deleteGroup(
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .user!
                                              .token,
                                          group.id)
                                      .then((_) {
                                    setState(() {
                                      _groupsFuture =
                                          _groupService.fetchMyGroups(
                                              Provider.of<UserProvider>(context,
                                                      listen: false)
                                                  .user!
                                                  .token,
                                              Provider.of<UserProvider>(context,
                                                      listen: false)
                                                  .user!
                                                  .id);
                                    });
                                  });
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.groupDeleted,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                } catch (error) {
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.groupDeleted,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                            )
                          : null,
                  onTap: () {
                    GoRouter.of(context).push('/group/${group.id}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
