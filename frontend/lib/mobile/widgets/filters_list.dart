import 'package:flutter/material.dart';

class FiltersList extends StatefulWidget {
  const FiltersList({super.key});

  @override
  _FiltersListState createState() => _FiltersListState();
}

class _FiltersListState extends State<FiltersList> {
  String selectedFilter = 'Mountain';

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        FilterChip(
          label: const Text('All'),
          selected: selectedFilter == 'All',
          onSelected: (bool selected) {
            setState(() {
              selectedFilter = 'All';
            });
          },
        ),
        FilterChip(
          label: const Text('Mountain'),
          selected: selectedFilter == 'Mountain',
          onSelected: (bool selected) {
            setState(() {
              selectedFilter = 'Mountain';
            });
          },
        ),
        FilterChip(
          label: const Text('Forest Trails'),
          selected: selectedFilter == 'Forest Trails',
          onSelected: (bool selected) {
            setState(() {
              selectedFilter = 'Forest Trails';
            });
          },
        ),
        // FilterChip(
        //   label: const Text('Coast'),
        //   selected: selectedFilter == 'Coast',
        //   onSelected: (bool selected) {
        //     setState(() {
        //       selectedFilter = 'Coast';
        //     });
        //   },
        // ),
      ],
    );
  }
}
