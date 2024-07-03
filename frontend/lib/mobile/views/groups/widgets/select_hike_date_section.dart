import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/group_provider.dart';

class SelectHikeDateSection extends StatelessWidget {
  const SelectHikeDateSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            'Select hike date',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2022, 1, 1),
            lastDate: DateTime(2050, 12, 31),
            onDateChanged: (date) {
              Provider.of<GroupProvider>(context, listen: false).selectDate(date);
            },
          ),
        ],
      ),
    );
  }
}
