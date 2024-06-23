import 'package:flutter/material.dart';

class SharedWidget extends StatelessWidget {
  final String title;
  SharedWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Text('Shared Widget: $title');
  }
}
