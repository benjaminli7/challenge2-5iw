import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';

class HikeDetailsSection extends StatelessWidget {
  final Hike hike;
  const HikeDetailsSection({super.key, required this.hike});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const CircleAvatar(
          backgroundImage: NetworkImage(
              "https://tse2.mm.bing.net/th?id=OIP.avb9nDfw3kq7NOoP0grM4wHaEK&pid=Api&P=0&w=300&h=300"), // Use your image asset or URL
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hike.name,
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
