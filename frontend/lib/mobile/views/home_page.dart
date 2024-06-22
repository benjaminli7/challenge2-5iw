import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/widgets/navbar.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/models/hike.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<HikeProvider>(context, listen: false).fetchHikes();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final hikeProvider = Provider.of<HikeProvider>(context);

    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        children: [
          Text(
            'Welcome ${user?.email}! ${user!.isVerified ? 'Your email is verified' : 'Please verify your email'}',
            style: const TextStyle(fontSize: 24),
          ),
          Expanded(
            child: hikeProvider.hikes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: hikeProvider.hikes.length,
              itemBuilder: (context, index) {
                Hike hike = hikeProvider.hikes[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://via.placeholder.com/150', // Placeholder image URL
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hike.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(hike.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
