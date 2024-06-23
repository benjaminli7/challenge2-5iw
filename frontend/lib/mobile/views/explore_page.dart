import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/mobile/widgets/search_bar.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      // top bar
      appBar: AppBar(
        // bold 24px text Poppins
        title: const Text(
          'Discover hiking trails \nnear you',
          style: TextStyle(
            fontSize: 24,
            //fontweight 600
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            letterSpacing: 0.55,
          ),
        ),
        // centerTitle: true,
      ),
      body: const Column(
        children: [
          // search bar
          SearchBarApp(
            hintText: 'Search for a trail',
          ),
        ],
      ),
    );
  }
}
