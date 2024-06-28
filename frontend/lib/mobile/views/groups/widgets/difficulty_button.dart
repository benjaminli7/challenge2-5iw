import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/group_provider.dart';

class DifficultyButton extends StatelessWidget {
  final String text;

  const DifficultyButton({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {

        Provider.of<GroupProvider>(context, listen: false).selectDifficulty(text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Button background color
      ),
      child: Text(text),
    );
  }
}
