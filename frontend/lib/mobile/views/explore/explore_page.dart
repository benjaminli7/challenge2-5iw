import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/mobile/views/explore/widgets/search_bar.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widgets/hike_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _isSortedAscending = false;
  String _searchQuery = '';
  String _sortCriteria = 'rating';

  @override
  void initState() {
    super.initState();
    _fetchHikes();
  }

  Future<void> _fetchHikes() async {
    await Provider.of<HikeProvider>(context, listen: false).fetchHikes();
  }

  void _filterHikes(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Hike> _getFilteredAndSortedHikes(List<Hike> hikes) {
    List<Hike> filteredHikes = hikes
        .where((hike) => hike.name.toLowerCase().contains(_searchQuery))
        .toList();

    filteredHikes.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'difficulty':
          comparison = _compareDifficulty(a.difficulty, b.difficulty);
          break;
        case 'duration':
          comparison = a.duration.compareTo(b.duration);
          break;
        case 'rating':
        default:
          comparison = a.averageRating.compareTo(b.averageRating);
          break;
      }
      return _isSortedAscending ? comparison : -comparison;
    });
    return filteredHikes;
  }

  int _compareDifficulty(String a, String b) {
    const difficultyOrder = {'Easy': 1, 'Moderate': 2, 'Hard': 3};
    return difficultyOrder[a]!.compareTo(difficultyOrder[b]!);
  }

  void _setSortCriteria(String? criteria) {
    if (criteria != null) {
      setState(() {
        _sortCriteria = criteria;
      });
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _isSortedAscending = !_isSortedAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortingText = _isSortedAscending
        ? AppLocalizations.of(context)!.lower
        : AppLocalizations.of(context)!.hightest;

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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            letterSpacing: 0.55,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchBarApp(
            hintText: AppLocalizations.of(context)!.searchTrail,
            onSearchChanged: _filterHikes,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _sortCriteria,
                  onChanged: _setSortCriteria,
                  items: [
                    DropdownMenuItem(
                        value: 'rating',
                        child:
                        Text(AppLocalizations.of(context)!.sort_by_Rating)),
                    DropdownMenuItem(
                        value: 'difficulty',
                        child: Text(
                            AppLocalizations.of(context)!.sort_by_Difficulty)),
                    DropdownMenuItem(
                        value: 'duration',
                        child: Text(
                            AppLocalizations.of(context)!.sort_by_Duration)),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sort),
                  label: Text(sortingText),
                  onPressed: _toggleSortOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<HikeProvider>(
              builder: (context, hikeProvider, child) {
                final approvedHikes =
                _getFilteredAndSortedHikes(hikeProvider.hikes)
                    .where((hike) => hike.isApproved)
                    .toList();
                return approvedHikes.isEmpty
                    ? Center(
                    child: Text(AppLocalizations.of(context)!.noHikesFound))
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
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
