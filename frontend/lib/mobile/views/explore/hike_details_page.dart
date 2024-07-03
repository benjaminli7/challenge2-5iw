import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/mobile/views/groups/createGroup_page.dart';

class HikeDetailsPage extends StatelessWidget {
  final Hike hike;

  const HikeDetailsPage({super.key, required this.hike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Details'),
      ),
      body: Padding(
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
            Image.network(
              Uri.parse("http://192.168.1.19:8080${hike.image}").toString(),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
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
          ],
        ),
      ),
    );
  }
}
