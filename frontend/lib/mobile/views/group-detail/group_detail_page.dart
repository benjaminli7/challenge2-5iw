import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/mobile/views/groups/widgets/weather/weather_widget.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/models/material.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:frontend/shared/services/material_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/shared/providers/settings_provider.dart';

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
  bool _isGroupInfoExpanded = true;
  bool _isMaterialsExpanded = false;
  bool _isWeatherExpanded = false;
  bool _isMembersExpanded = false;
  bool _isWeatherApiEnabled = false;
  Group? _group;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.fetchSettings();
    _isWeatherApiEnabled = _settingsProvider.settings.weatherAPI;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupFuture = _groupService.getGroupById(user.token, widget.groupId);
      _materialsFuture =
          _materialService.getMaterialsByGroupId(user.token, widget.groupId);
    } else {
      _groupFuture = Future.error(AppLocalizations.of(context)!.userNotLogged);
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
          title: Text(AppLocalizations.of(context)!.addMaterial),
          content: TextField(
            controller: _materialController,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterMaterial),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.submit),
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
                      msg: AppLocalizations.of(context)!.materialAdd,
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

  Future<void> _removeUserFromGroup(int userId) async {
    final token = Provider.of<UserProvider>(context, listen: false).user?.token;
    if (token != null) {
      final response =
          await _groupService.deleteUserGroup(token, widget.groupId, userId);
      if (response.statusCode == 200) {
        setState(() {
          _group?.users.removeWhere((user) => user.id == userId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.failedRemoveUser)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groupDetail),
      ),
      body: FutureBuilder<Group>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noGroupFound));
          } else {
            _group = snapshot.data!;
            final group = _group!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAccordion(
                      title: 'Group information',
                      isExpanded: _isGroupInfoExpanded,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isGroupInfoExpanded = expanded;
                        });
                      },
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${group.name} (${group.hike.name})",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  text: AppLocalizations.of(context)!
                                          .description +
                                      ': ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: group.description,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 16.0),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      AppLocalizations.of(context)!.startDate +
                                          ': ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: DateFormat('dd/MM/yyyy')
                                          .format(group.startDate),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 16.0),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  text: AppLocalizations.of(context)!
                                          .currentGroupSize +
                                      ': ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${group.users.length} / ${group.maxUsers}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 16.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.groupCreatedBy(
                                  group.organizer.username.toString()),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    CustomAccordion(
                      title: AppLocalizations.of(context)!.material,
                      isExpanded: _isMaterialsExpanded,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isMaterialsExpanded = expanded;
                        });
                      },
                      content: Column(
                        children: [
                          FutureBuilder<List<Materiel>>(
                            future: _materialsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .noMaterial));
                              } else {
                                final materials = snapshot.data!;
                                return Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: materials.length,
                                      itemBuilder: (context, index) {
                                        final material = materials[index];
                                        bool isBringer = material.users
                                            .any((u) => u.id == user?.id);
                                        return ListTile(
                                            visualDensity: const VisualDensity(
                                                vertical: 2),
                                            leading: Checkbox(
                                              value: isBringer,
                                              onChanged: (bool? value) {
                                                if (value != null &&
                                                    user != null) {
                                                  _updateBringer(
                                                      material, user, value);
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
                                                              .users[i]
                                                              .username!
                                                              .substring(0, 1)
                                                              .toUpperCase())))
                                              ],
                                            ));
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16.0),
                          if (user != null && group.organizer.id == user.id)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 16.0),
                              label: Text(
                                  AppLocalizations.of(context)!.addMaterial),
                              onPressed: () {
                                _showAddMaterialDialog(context);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    CustomAccordion(
                      title: AppLocalizations.of(context)!.members,
                      isExpanded: _isMembersExpanded,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isMembersExpanded = expanded;
                        });
                      },
                      content: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: group.users.length,
                        itemBuilder: (context, index) {
                          final member = group.users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(member.username!
                                  .substring(0, 1)
                                  .toUpperCase()),
                            ),
                            title: Text(
                              "${member.username!} ${group.organizer.id == member.id ? '(Admin)' : ''}",
                            ),
                            trailing: group.organizer.id != member.id &&
                                    user != null &&
                                    group.organizer.id == user.id
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await _removeUserFromGroup(member.id);
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    _isWeatherApiEnabled
                        ? Column(
                            children: [
                              CustomAccordion(
                                title: AppLocalizations.of(context)!.weather,
                                isExpanded: _isWeatherExpanded,
                                onExpansionChanged: (bool expanded) {
                                  setState(() {
                                    _isWeatherExpanded = expanded;
                                  });
                                },
                                content: WeatherWidget(group: group),
                              ),
                              const SizedBox(height: 8.0),
                              const Divider(),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(height: 8.0),
                    ListTile(
                        title: const Text('Photos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onTap: () {
                          GoRouter.of(context)
                              .push('/group/${group.id}/photos');
                        }),
                    const SizedBox(height: 8.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat, size: 16.0),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        GoRouter.of(context).push('/group-chat/${group.id}');
                      },
                      label: Text(AppLocalizations.of(context)!.groupChat),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CustomAccordion extends StatelessWidget {
  final String title;
  final Widget content;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;

  const CustomAccordion({
    super.key,
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.zero,
      expansionCallback: (int index, bool isExpanded) {
        onExpansionChanged(isExpanded);
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
          isExpanded: isExpanded,
        ),
      ],
    );
  }
}
