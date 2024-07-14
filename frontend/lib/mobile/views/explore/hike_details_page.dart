import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/explore/widgets/open_runner.dart';
import 'package:frontend/mobile/views/explore/widgets/review_widget.dart';
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
      _groupsFuture = Future.error('User not logged in');
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
            content: Text('Joined group ${group.id} successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          // Re-fetch groups to update the list after joining a group
          _groupsFuture = _groupService.fetchHikeGroups(
              user.token, widget.hike.id, user.id);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group ${group.id}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Details'),
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
                      const Text('Difficulty level',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.hike.difficulty,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Duration',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.hike.duration,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const Text(
                'Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Group>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: const CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No groups found for this hike'));
                  } else {
                    List<Group> groups = snapshot.data!;
                    if (_selectedDate != null) {
                      groups = groups.where((group) {
                        return group.startDate
                                .isAtSameMomentAs(_selectedDate!) ||
                            group.startDate.isAfter(_selectedDate!);
                      }).toList();
                    }
                    return Column(
                      children: groups
                          .map((group) => _buildGroupCard(group))
                          .toList(),
                    );
                  }
                },
              ),
              const Divider(),
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ReviewWidget(hikeId: widget.hike.id),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context)
                        .push('/hike/${widget.hike.id}/reviews');
                  },
                  child: const Text('View All Reviews'),
                ),
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

  Widget _buildGroupCard(Group group) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.organizer.email,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                'Start Date: ${DateFormat('dd/MM/yyyy').format(group.startDate)}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _joinGroup(group),
              child: const Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }
}
