import 'package:flutter/material.dart';

class SelectStartTimeSection extends StatefulWidget {
  const SelectStartTimeSection({Key? key}) : super(key: key);

  @override
  _SelectStartTimeSectionState createState() => _SelectStartTimeSectionState();
}

class _SelectStartTimeSectionState extends State<SelectStartTimeSection> {

  final List<String> _times = [
    '01:00am',
    '02:00am',
    '03:00am',
    '04:00am',
    '05:00am',
    '06:00am',
    '07:00am',
    '08:00am',
    '09:00am',
    '10:00am',
    '11:00am',
    '12:00am',
    '01:00pm',
    '02:00pm',
    '03:00pm',
    '04:00pm',
    '05:00pm',
    '06:00pm',
    '07:00pm',
    '08:00pm',
    '09:00pm',
    '10:00pm',
    '11:00pm',
    '12:00pm',
  ];

  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = _times.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Select start time',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _selectedTime,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.black,
            underline: Container(
              height: 2,
              color: Colors.white,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTime = newValue;
                // Ici, vous pouvez gérer la sélection de l'heure
              });
            },
            items: _times.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
