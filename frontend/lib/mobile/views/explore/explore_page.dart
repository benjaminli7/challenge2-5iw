import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/create-hike/create_hike_page.dart';
import 'package:frontend/mobile/views/explore/widgets/search_bar.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/hike_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    _fetchHikes();
  }

  Future<void> _fetchHikes() async {
    await Provider.of<HikeProvider>(context, listen: false).fetchHikes();
    setState(() {
      filteredHikes = Provider.of<HikeProvider>(context, listen: false).hikes;
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
    final sortingText = _isSortedAscending ? 'Sort by Best Rating' : 'Sort by Worst Rating';

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/create-hike');
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.discoverHike,
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
            hintText: AppLocalizations.of(context)!.searchTrail,
            onSearchChanged: _filterHikes,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.sort),
              label: Text(sortingText),
              onPressed: _sortHikesByRating,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<HikeProvider>(
              builder: (context, hikeProvider, child) {
                final approvedHikes = filteredHikes.where((hike) => hike.isApproved).toList();
                return approvedHikes.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.noHikesFound))
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
