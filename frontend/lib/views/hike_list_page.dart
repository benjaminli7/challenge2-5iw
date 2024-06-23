import 'package:flutter/material.dart';
import '../widgets/filters_list.dart';

class HikeListPage extends StatelessWidget {
  const HikeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Hiking Trails'),
      ),
      body: Column(
        children: [
          //const FiltersList(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 26.0,
              ),
              itemCount: hikeData.length,
              itemBuilder: (context, index) {
                return HikeCard(
                  image: hikeData[index]['image']!,
                  title: hikeData[index]['title']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HikeCard extends StatelessWidget {
  final String image;
  final String title;

  const HikeCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, String>> hikeData = [
  {
    'image': 'assets/desert.jpeg',
    'title': 'Rocky Mountains',
    'category': 'montain'
  },
  {
    'image': 'assets/foret.jpeg',
    'title': 'Redwood Forest',
    'category': 'forest'
  },
  {
    'image': 'assets/jungle.jpeg',
    'title': 'Appalachian Trail',
    'category': 'forest'
  },
  {
    'image': 'assets/montagne.jpeg',
    'title': 'Yosemite National Park',
    'category': 'montain'
  },
  {
    'image': 'assets/foret.jpeg',
    'title': 'Pacific Crest Trail',
    'category': 'coast'
  },
  {
    'image': 'assets/montagne.jpeg',
    'title': 'Grand Canyon',
    'category': 'montain'
  },
  {
    'image': 'assets/jungle.jpeg',
    'title': 'Zion National Park',
    'category': 'montain'
  },
  {
    'image': 'assets/desert.jpeg',
    'title': 'Yellowstone Park',
    'category': 'montain'
  },
];
