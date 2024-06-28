import 'package:flutter/material.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:provider/provider.dart';

class CreateHikePage extends StatefulWidget {
  const CreateHikePage({super.key});

  @override
  State<CreateHikePage> createState() => _CreateHikePageState();
}

class _CreateHikePageState extends State<CreateHikePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _difficulty = 'Easy';
  final _durationController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _createHike() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final hike = <String, dynamic>{
        'name': _nameController.text,
        'description': _descriptionController.text,
        'difficulty': _difficulty,
        'duration': _durationController.text,
      };

      final response = await _apiService.createHike(
        hike['name'],
        hike['description'],
        user!.id,
        hike['difficulty'],
        hike['duration'],
      );
      // print response json
      print(response.body);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Hike'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the hike';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(labelText: 'Difficulty'),
                items: ['Easy', 'Moderate', 'Hard']
                    .map((difficulty) => DropdownMenuItem<String>(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a difficulty level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (hours)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration of the hike';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Data')),
                    );
                    // print the form values
                    print(_nameController.text);
                    print(_descriptionController.text);
                    print(_difficulty);
                    print(_durationController.text);

                    _createHike();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
