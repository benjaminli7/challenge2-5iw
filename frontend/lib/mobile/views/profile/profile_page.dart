import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isChangingPassword = false;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _userProvider = UserProvider();


  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user?.token;
    if (token != null) {
      final success = await userProvider.changePassword(
        token,
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      if (success) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.passwordChanged,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        setState(() {
          _isChangingPassword = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.passwordChangeFailed,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.no_user_data_available,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _pickImage() async {


    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);


      if (_userProvider.user  != null) {


        await _userProvider.updateUser(_userProvider.user!, file);

        _userProvider.user!.profileImage = file.path;
        var userTest = Provider.of<UserProvider>(context).user;
        print(userTest?.username);
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.profilePictureUpdated,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.no_user_data_available,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.profilePictureUpdateFailed,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    print(user);
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
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                            ? NetworkImage('$baseUrl${user.profileImage}')
                            : null,
                        child: user.profileImage == null ||
                            user.profileImage!.isEmpty
                            ? Text(
                          user.username!
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 48.0),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username ??
                        AppLocalizations.of(context)!.no_Username,
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
                    leading: const Icon(Icons.history,
                        color: Colors.blueAccent),
                    title: Text(
                        AppLocalizations.of(context)!.hike_History),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      GoRouter.of(context).go('/profile/hike-history');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                    const Icon(Icons.vpn_key, color: Colors.orange),
                    title: Text(
                        AppLocalizations.of(context)!.changePassword),
                    trailing: Icon(
                      _isChangingPassword
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 38,
                    ),
                    onTap: () {
                      setState(() {
                        _isChangingPassword = !_isChangingPassword;
                      });
                    },
                  ),
                  if (_isChangingPassword)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _oldPasswordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .oldPassword,
                            ),
                            obscureText: true,
                          ),
                          TextField(
                            controller: _newPasswordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .newPassword,
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _changePassword,
                            child: Text(AppLocalizations.of(context)!
                                .changePassword),
                          ),
                        ],
                      ),
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(AppLocalizations.of(context)!.signOut),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Provider.of<UserProvider>(context, listen: false)
                          .clearUser();
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.disconnected,
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
          : Center(
        child: Text(AppLocalizations.of(context)!.no_user_data_available),
      ),
    );
  }
}
