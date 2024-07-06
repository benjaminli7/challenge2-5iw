import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/mobile/views/explore/widgets/group_list.dart';
import 'package:frontend/shared/models/group.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:frontend/mobile/views/groups/createGroup_page.dart';

class HikeDetailsPage extends StatefulWidget {
  final Hike hike;

  const HikeDetailsPage({super.key, required this.hike});

  @override
  _HikeDetailsPageState createState() => _HikeDetailsPageState();
}

class _HikeDetailsPageState extends State<HikeDetailsPage> {
  late Future<List<Group>> _groupsFuture;
  final GroupService _groupService = GroupService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _groupsFuture = _groupService.fetchHikeGroups(user.token, widget.hike.id);
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
              // Assurez-vous que l'image a une taille définie
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  Uri.parse("http://192.168.1.110:8080${widget.hike.image}").toString(),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Difficulty level'),
                      SizedBox(height: 8),
                      Text('Intermediate'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Duration'),
                      SizedBox(height: 8),
                      Text('3 hours'),
                    ],
                  ),
                ],
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
              SizedBox(
                height: 400, // Par exemple, une hauteur fixe pour éviter le problème de taille indéfinie
                child: FutureBuilder<List<Group>>(
                  future: _groupsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No groups found for this hike'));
                    } else {
                      List<Group> groups = snapshot.data!;
                      if (_selectedDate != null) {
                        groups = groups.where((group) {
                          return group.startDate.isAtSameMomentAs(_selectedDate!) ||
                              group.startDate.isAfter(_selectedDate!);
                        }).toList();
                      }
                      return GroupList(groups: groups);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGroupPage(hike: widget.hike),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
