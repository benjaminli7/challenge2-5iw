import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  File? _image;
  File? _gpxFile;

  final ImagePicker _picker = ImagePicker();

  void _createHike() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final hike = <String, dynamic>{
        'name': _nameController.text,
        'description': _descriptionController.text,
        'difficulty': _difficulty,
        'duration': _durationController.text,
        'image': _image,
        'gpx_file': _gpxFile,
      };

      await _apiService.createHike(
        hike['name'],
        hike['description'],
        user!.id,
        hike['difficulty'],
        hike['duration'],
        hike['image'],
        hike['gpx_file'],
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _pickGPXFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _gpxFile = File(result.files.single.path!);
      });
    } else {
      print('No GPX file selected.');
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
        title: const Text('Create Hike'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the hike';
                  }
                  if (value.length > 100) {
                    return 'Name cannot be longer than 100 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length > 280) {
                    return 'Description cannot be longer than 280 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
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
                decoration:
                const InputDecoration(labelText: 'Duration (hours)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration of the hike';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0 || double.parse(value) >= 96) {
                    return 'Duration must be between 0 and 96h (its not Trekking!)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 20),
              _gpxFile == null
                  ? const Text('No GPX file selected.')
                  : Text(_gpxFile!.path),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickGPXFile,
                child: const Text('Upload GPX File'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    _createHike();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
