import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch; // Callback function to handle search
  const SearchBarApp({Key? key, this.hintText = '', required this.onSearch})
      : super(key: key);

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch, // Call onSearch callback on text change
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
