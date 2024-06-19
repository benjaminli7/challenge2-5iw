import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('LeafMeet'),
      centerTitle: true,
      //add drawer burger icon

      // actions: [
      //   Consumer<UserProvider>(
      //     builder: (context, userProvider, child) {
      //       if (userProvider.user != null) {
      //         return IconButton(
      //           icon: const Icon(Icons.logout),
      //           onPressed: () {
      //             // Clear the user from the provider
      //             userProvider.clearUser();

      //             Fluttertoast.showToast(
      //               msg: "Disconnected",
      //               toastLength: Toast.LENGTH_SHORT,
      //               gravity: ToastGravity.BOTTOM,
      //               backgroundColor: Colors.black,
      //               textColor: Colors.white,
      //             );
      //             Navigator.pushReplacementNamed(context, '/login');
      //           },
      //         );
      //       } else {
      //         return Container(); // Return an empty container if no user is connected
      //       }
      //     },
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
