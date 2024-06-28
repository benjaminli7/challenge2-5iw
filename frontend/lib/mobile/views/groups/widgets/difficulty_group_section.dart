import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/mobile/views/groups/widgets/difficulty_button.dart';

class DifficultyGroupSection extends StatelessWidget {
  const DifficultyGroupSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Difficulty',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const DifficultyButton(text: 'Snail'),
              const SizedBox(width: 10),
              const DifficultyButton(text: 'Goat'),
              const SizedBox(width: 10),
              const DifficultyButton(text: 'Jaguar'),
            ],
          ),
        ],
      ),
    );
  }
}
