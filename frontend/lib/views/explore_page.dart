import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/search_bar.dart';
import '../views/hike_list_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      // top bar
      appBar: AppBar(
        scrolledUnderElevation: 0,

        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
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
        //
      ),
      body: const Column(
        children: [
          // search bar
          SearchBarApp(
            hintText: 'Search for a trail',
          ),
          // list of hikes
          Expanded(
            child: HikeListPage(),
          ),
        ],
      ),
    );
  }
}
