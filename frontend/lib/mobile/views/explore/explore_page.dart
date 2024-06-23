import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/search_bar.dart';
import 'hike_list_page.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/mobile/widgets/search_bar.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/services/api_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final apiService = ApiService(); // Create instance of ApiService
  late List<dynamic> allHikes;
  late List<dynamic> filteredHikes;

  @override
  void initState() {
    super.initState();
    fetchHikes();
  }

  Future<void> fetchHikes() async {
    final List<dynamic> hikes = await apiService.getHikes();
    setState(() {
      allHikes = hikes;
      filteredHikes =
          List.from(allHikes); // Initialize filteredHikes with allHikes
    });
  }

  void filterHikes(String searchTerm) {
    setState(() {
      filteredHikes = allHikes.where((hike) {
        return hike['title'].toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Discover hiking trails \nnear you',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              letterSpacing: 0.55,
            ),
          ),
        ),
      ),
      body: allHikes == null // Show loading indicator while fetching hikes
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SearchBarApp(
                  hintText: 'Search for a trail',
                  onSearch:
                      filterHikes, // Pass filterHikes function to SearchBarApp
                ),
                Expanded(
                  child: HikeListPage(
                    hikes: filteredHikes, // Pass filteredHikes to HikeListPage
                  ),
                ),
              ],
            ),
    );
  }
}
