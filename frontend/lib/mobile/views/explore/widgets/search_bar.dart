import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;

  const SearchBarApp(
      {required this.hintText, required this.onSearchChanged, super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  @override
  Widget build(BuildContext context) {
    print('Building SearchBarApp');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.all(10),
      child: TextField(
        onChanged: (value) {
          widget.onSearchChanged(value);
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          suffixIcon: const Icon(Icons.search),
          hintText: widget.hintText.isNotEmpty ? widget.hintText : 'Search',
        ),
      ),
    );
  }
}
