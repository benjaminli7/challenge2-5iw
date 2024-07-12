import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
                  Uri.parse("${dotenv.env['BASE_URL']}${hike.image}")
                      .toString(),
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
