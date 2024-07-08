import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/mobile/views/explore/hike_details_page.dart';
import 'package:go_router/go_router.dart';

class HikeCard extends StatelessWidget {
  final Hike hike;

  const HikeCard({super.key, required this.hike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HikeDetailsPage(hike: hike),
            ),
          );

        },
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  Uri.parse("http://192.168.1.94:8080${hike.image}").toString(),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  hike.name,
                  style: const TextStyle(
                      fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ));
  }
}
