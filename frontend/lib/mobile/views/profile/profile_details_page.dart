import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String baseUrl = ConfigService.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user?.token;
    if (token != null) {
      await userProvider.fetchUserProfile(token);
      final user = userProvider.user;
      if (user != null) {
        _usernameController.text = user.username ?? '';
        print('User information on init: ${user.toJson()}');
      }
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user!;
      final token = user.token;
      user.username = _usernameController.text;

      try {
        await userProvider.updateUser(user);
        user.token = token;
        userProvider.setUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        print('User information after update: ${user.toJson()}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (user != null) ...[
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${user.role}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verified: ${user.isVerified}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildProfileForm(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateProfile,
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Action for changing password
          },
          child: const Text('Change Password'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}
