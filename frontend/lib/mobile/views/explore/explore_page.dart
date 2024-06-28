import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/create-hike/create_hike_page.dart';
import 'package:frontend/mobile/views/explore/widgets/search_bar.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/hike_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Hike> filteredHikes = [];

  @override
  void initState() {
    super.initState();
    // Fetch hikes and set the filtered hikes
    Provider.of<HikeProvider>(context, listen: false).fetchHikes().then((_) {
      setState(() {
        filteredHikes = Provider.of<HikeProvider>(context, listen: false).hikes;
      });
    });
  }

  void _filterHikes(String query) {
    final hikes = Provider.of<HikeProvider>(context, listen: false).hikes;
    setState(() {
      filteredHikes = hikes
          .where(
              (hike) => hike.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building ExplorePage'); // Debugging print statement
    final user = Provider.of<UserProvider>(context).user;
    final hikeProvider = Provider.of<HikeProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateHikePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text(
          'Discover hiking trails \nnear you',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            letterSpacing: 0.55,
          ),
        ),
      ),
      body: Column(
        children: [
          SearchBarApp(
            hintText: 'Search for a trail',
            onSearchChanged: _filterHikes,
          ),
          Expanded(
            child: hikeProvider.hikes.isEmpty
                ? const Center(child: Text("No hikes found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 26.0,
                    ),
                    itemCount: filteredHikes.length,
                    itemBuilder: (context, index) {
                      return HikeCard(hike: filteredHikes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
