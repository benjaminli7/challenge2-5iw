import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final String baseUrl = ConfigService.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user != null
          ? SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage('$baseUrl${user.profileImage}')
                        : const AssetImage('assets/images/profile_placeholder.png')
                    as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username ?? 'No Username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.history, color: Colors.blueAccent),
                    title: Text('Hike History'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      GoRouter.of(context).go('/profile/hike-history');
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Sign Out'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Provider.of<UserProvider>(context, listen: false).clearUser();
                      Fluttertoast.showToast(
                        msg: "Disconnected",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                      GoRouter.of(context).go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : const Center(child: Text('No user data available')),
    );
  }
}
