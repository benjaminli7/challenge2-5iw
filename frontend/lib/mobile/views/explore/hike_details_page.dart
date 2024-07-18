import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/mobile/views/explore/widgets/open_runner.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/services/config_service.dart';

class HikeDetailsExplorePage extends StatefulWidget {
  final Hike hike;

  const HikeDetailsExplorePage({Key? key, required this.hike})
      : super(key: key);

  @override
  _HikeDetailsExplorePageState createState() => _HikeDetailsExplorePageState();
}

class _HikeDetailsExplorePageState extends State<HikeDetailsExplorePage> {
  String baseUrl = ConfigService.baseUrl;
  late Future<List<Group>> _groupsFuture;
  final GroupService _groupService = GroupService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupsFuture =
          _groupService.fetchHikeGroups(user.token, widget.hike.id, user.id);
    } else {
      _groupsFuture = Future.error(AppLocalizations.of(context)!.userNotLogged);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _joinGroup(Group group) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      try {
        await _groupService.joinGroup(user.token, group.id, user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.joinGroupSuccess(group.id)),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _groupsFuture = _groupService.fetchHikeGroups(
              user.token, widget.hike.id, user.id);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .joinGroupFailure(group.id, e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.userNotLogged),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hikeDetails),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.hike.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  Uri.parse("$baseUrl${widget.hike.image}").toString(),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(AppLocalizations.of(context)!.difficulty,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.hike.difficulty,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(AppLocalizations.of(context)!.durationHour,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.hike.duration.toString(),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.description,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.hike.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.hike.gpxFile.isNotEmpty)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 300,
                    child: GPXMapScreen(hike: widget.hike),
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.groups,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Group>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return CarouselSlider(
                        items: [
                          Center(
                              child: Text(
                                  AppLocalizations.of(context)!.noGroupFound))
                        ],
                        options: CarouselOptions(
                          height: 200,
                          enableInfiniteScroll: false,
                        ));
                  } else {
                    List<Group> groups = snapshot.data!;
                    if (_selectedDate != null) {
                      groups = groups.where((group) {
                        return group.startDate
                                .isAtSameMomentAs(_selectedDate!) ||
                            group.startDate.isAfter(_selectedDate!);
                      }).toList();
                    }
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        enableInfiniteScroll: false,
                      ),
                      items: groups.map((group) {
                        int currentParticipants = group.users.length;
                        return Builder(
                          builder: (BuildContext context) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      group.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(group.startDate),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      group.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            disabledBackgroundColor:
                                                Colors.grey,
                                            backgroundColor: Colors.green),
                                        onPressed: currentParticipants ==
                                                group.maxUsers
                                            ? null
                                            : () => _joinGroup(group),
                                        child: Text(
                                            '${AppLocalizations.of(context)!.joinGroup} ($currentParticipants/${group.maxUsers})',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: Text(AppLocalizations.of(context)!.viewReviews),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).push('/hike/${widget.hike.id}/reviews');
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go('/groups/create/${widget.hike.id}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
