import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/explore/widgets/review_widget.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/mobile/views/groups/createGroup_page.dart';
import 'package:frontend/mobile/views/explore/widgets/open_runner.dart';

class HikeDetailsExplorePage extends StatelessWidget {
  final Hike hike;

  const HikeDetailsExplorePage({super.key, required this.hike});

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
                  hike.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  Uri.parse("http://10.0.2.2:8080${hike.image}").toString(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Difficulty level', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(hike.difficulty, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(hike.duration, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 300,
                  child: GPXMapScreen(hike: hike),
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
              ListTile(
                title: const Text('Create Group'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroupPage(hike: hike),
                    ),
                  );
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
              ReviewWidget(hikeId: hike.id),
            ],
          ),
        ),
      ),
    );
  }
}
