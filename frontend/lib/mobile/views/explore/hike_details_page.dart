import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/mobile/views/groups/createGroup_page.dart';

class HikeDetailsPage extends StatelessWidget {
  final Hike hike;

  const HikeDetailsPage({Key? key, required this.hike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                hike.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Image.network(
              'https://via.placeholder.com/300',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            SizedBox(height: 16),
            Row(
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
            SizedBox(height: 16),
            Text(
              'Groups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              title: Text('Create Group'),
              trailing: Icon(Icons.chevron_right),
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
