import 'package:flutter/material.dart';
import '../../widgets/hike_card.dart';

class HikeListPage extends StatelessWidget {
  final List<dynamic> hikes;

  const HikeListPage({Key? key, required this.hikes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Hiking Trails'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 26.0,
              ),
              itemCount: hikes.length,
              itemBuilder: (context, index) {
                return HikeCard(
                  image: "lib/shared/assets/" + hikes[index]['image']!,
                  title: hikes[index]['name']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
