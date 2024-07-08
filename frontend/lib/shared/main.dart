import 'package:flutter/material.dart';

class SharedWidget extends StatelessWidget {
  final String title;
  const SharedWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Shared Widget: $title');
  }
}
