import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
        'duration': int.parse(_durationController.text),
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

      GoRouter.of(context).push('/explore');
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'], // Ensure no dot before the extension
      );

      print('File picking result: $result'); // Debug print

      if (result != null && result.files.single.path != null) {
        setState(() {
          _gpxFile = File(result.files.single.path!);
          print('GPX file path: ${_gpxFile!.path}'); // Debug print
        });
      } else {
        print('No GPX file selected.');
      }
    } catch (e) {
      print('Error picking GPX file: $e');
      print('Attempting to use FileType.any as a fallback');

      // Fallback to FileType.any
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _gpxFile = File(result.files.single.path!);
            print(
                'GPX file path with fallback: ${_gpxFile!.path}'); // Debug print
          });
        } else {
          print('No file selected in fallback.');
        }
      } catch (e) {
        print('Error picking file in fallback: $e');
      }
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
        title: Text(AppLocalizations.of(context)!.createHike),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterNameHike;
                  }
                  if (value.length > 50) {
                    return AppLocalizations.of(context)!.nameHike50;
                  }
                  final validName = RegExp(r'^[a-zA-Z0-9\s]+$');
                  if (!validName.hasMatch(value)) {
                    return AppLocalizations.of(context)!.nameHikeAlpha;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterDescriptionHike;
                  }
                  if (value.length > 50) {
                    return AppLocalizations.of(context)!.descriptionHike50;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.difficulty),
                items: ['Easy', 'Medium', 'Hard']
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
                    return AppLocalizations.of(context)!.selectDifficulty;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.durationHour,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterDurationHike;
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0 || number >= 96) {
                    return AppLocalizations.of(context)!.durationBetween;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _image == null
                  ? Text(AppLocalizations.of(context)!.noImage)
                  : Image.file(_image!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(AppLocalizations.of(context)!.uploadImage),
              ),
              const SizedBox(height: 20),
              _gpxFile == null
                  ? Text(AppLocalizations.of(context)!.noGpxFile)
                  : Text(_gpxFile!.path),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickGPXFile,
                child: Text(AppLocalizations.of(context)!.uploadGpx),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.processingData)),
                    );
                    _createHike();
                  }
                },
                child: Text(AppLocalizations.of(context)!.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
