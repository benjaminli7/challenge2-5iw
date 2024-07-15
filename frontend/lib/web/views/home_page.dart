import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/widgets/navbar.dart';
import 'package:frontend/shared/providers/user_provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    print(user);
    return Scaffold(
      appBar: const NavBar(),
      body: Center(
        child: Text(
          'Welcome ${user?.email}! in the Admin Dashboard',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
