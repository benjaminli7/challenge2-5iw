import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:go_router/go_router.dart';

class HikeCard extends StatelessWidget {
  final Hike hike;

  const HikeCard({super.key, required this.hike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          GoRouter.of(context).push('/hike/${hike.id}');
        },
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  Uri.parse("http://10.0.2.2:8080${hike.image}").toString(),

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
