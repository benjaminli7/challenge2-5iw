import 'package:flutter/material.dart';

class HikeCard extends StatelessWidget {
  final String image;
  final String title;

  const HikeCard({Key? key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
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
                  const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
