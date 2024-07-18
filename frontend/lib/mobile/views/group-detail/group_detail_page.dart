import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:frontend/mobile/views/groups/widgets/weather/weather_widget.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/models/material.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:frontend/shared/services/material_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _groupService = GroupService();
  final _materialService = MaterialService();
  late Future<Group> _groupFuture;
  late Future<List<Materiel>> _materialsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupFuture = _groupService.getGroupById(user.token, widget.groupId);
      _materialsFuture =
          _materialService.getMaterialsByGroupId(user.token, widget.groupId);
    } else {
      _groupFuture = Future.error('User not logged in');
    }
  }

  Future<void> _refreshMaterials() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _materialsFuture =
            _materialService.getMaterialsByGroupId(user.token, widget.groupId);
      });
    }
  }

  void _showAddMaterialDialog(BuildContext context) {
    final TextEditingController _materialController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Material'),
          content: TextField(
            controller: _materialController,
            decoration: const InputDecoration(hintText: "Enter material name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                final user =
                    Provider.of<UserProvider>(context, listen: false).user;
                if (user != null) {
                  await _materialService.addMaterials(
                    user.token,
                    widget.groupId.toString(),
                    [_materialController.text],
                  );
                  _refreshMaterials();
                  Fluttertoast.showToast(
                      msg: "Material added successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBringer(Materiel material, User user, bool add) async {
    final token = Provider.of<UserProvider>(context, listen: false).user?.token;
    if (token != null) {
      if (add) {
        await _materialService.addBringer(token, material.id, user.id);
      } else {
        await _materialService.removeBringer(token, material.id, user.id);
      }
      await _refreshMaterials();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
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
                    'Name: ${group.name}',
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
                  SizedBox(
                    height: 200, // Adjust the height as needed
                    child: FutureBuilder<List<Materiel>>(
                      future: _materialsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return const Center(
                              child: Text('No materials found'));
                        } else {
                          final materials = snapshot.data!;
                          return ListView.builder(
                            itemCount: materials.length,
                            itemBuilder: (context, index) {
                              final material = materials[index];
                              bool isBringer =
                                  material.users.any((u) => u.id == user?.id);
                              return ListTile(
                                  visualDensity:
                                      const VisualDensity(vertical: 2),
                                  leading: Checkbox(
                                    value: isBringer,
                                    onChanged: (bool? value) {
                                      if (value != null && user != null) {
                                        _updateBringer(material, user, value);
                                      }
                                    },
                                  ),
                                  title: Row(
                                    children: [
                                      Text(material.name),
                                      const SizedBox(width: 16),
                                      for (int i = 0;
                                          i < material.users.length;
                                          i++)
                                        Align(
                                            widthFactor: 0.75,
                                            child: CircleAvatar(
                                                radius: 15,
                                                child: Text(material
                                                    .users[i].username!
                                                    .substring(0, 1)
                                                    .toUpperCase())))
                                    ],
                                  ));
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (user != null && group.organizer.id == user.id)
                    ElevatedButton(
                      child: const Text("Add a material"),
                      onPressed: () {
                        _showAddMaterialDialog(context);
                      },
                    ),
                  const SizedBox(height: 5.0),
                  if (user != null && group.organizer.id == user.id)
                    ElevatedButton(
                      child: const Text("Edit Group"),
                      onPressed: () {
                        GoRouter.of(context).push('/group-users/${group.id}');
                      },
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
                  // Expanded(
                  //   child: WeatherWidget(
                  //     group: group,
                  //   ),
                  // )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
