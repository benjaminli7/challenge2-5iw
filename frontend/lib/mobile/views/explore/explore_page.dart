import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/create-hike/create_hike_page.dart';
import 'package:frontend/mobile/views/explore/widgets/search_bar.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'widgets/hike_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});


  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Hike> filteredHikes = [];
  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
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
          .where((hike) => hike.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _sortHikesByRating() {
    setState(() {
      if (_isSortedAscending) {
        filteredHikes.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      } else {
        filteredHikes.sort((a, b) => a.averageRating.compareTo(b.averageRating));
      }
      _isSortedAscending = !_isSortedAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hikeProvider = Provider.of<HikeProvider>(context);
    final approvedHikes =
        filteredHikes.where((hike) => hike.isApproved).toList();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/create-hike');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _sortHikesByRating,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarApp(
            hintText: 'Search for a trail',
            onSearchChanged: _filterHikes,
          ),
          Expanded(
            child: approvedHikes.isEmpty
                ? const Center(child: Text("No hikes found"))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 26.0,
              ),
              itemCount: approvedHikes.length,
              itemBuilder: (context, index) {
                return HikeCard(hike: approvedHikes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
