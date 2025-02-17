import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateHikePage extends StatefulWidget {
  const CreateHikePage({super.key});

  @override
  State<CreateHikePage> createState() => _CreateHikePageState();
}

class _CreateHikePageState extends State<CreateHikePage> {
  final API_KEY = dotenv.env['LOC_API_URL'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mapsController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _difficulty = 'Easy';
  final _durationController = TextEditingController();
  final ApiService _apiService = ApiService();
  File? _image;
  File? _gpxFile;
  final _lat = TextEditingController();
  final _lng = TextEditingController();

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
        'lat': _lat.text,
        'lng': _lng.text,
      };

      final res = await _apiService.createHike(
          hike['name'],
          hike['description'],
          user!.id,
          hike['difficulty'],
          hike['duration'],
          hike['image'],
          hike['gpx_file'],
          hike['lat'],
          hike['lng'],
          user.token);

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.successCreateHike,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (res.statusCode == 405) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final String? errMessage = responseData['message'];
        Fluttertoast.showToast(
          msg: errMessage!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      GoRouter.of(context).push('/explore');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickGPXFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _gpxFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _gpxFile = File(result.files.single.path!);
          });
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
    _lat.dispose();
    _lng.dispose();
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
              GooglePlacesAutoCompleteTextFormField(
                  textEditingController: _mapsController,
                  googleAPIKey: API_KEY!,
                  debounceTime: 400,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    _lat.text = prediction.lat.toString();
                    _lng.text = prediction.lng.toString();
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterAdress,
                    labelText: AppLocalizations.of(context)!.adress,
                  ),
                  itmClick: (Prediction prediction) {
                    _mapsController.text = prediction.description.toString();
                    _mapsController.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description!.length));
                  }),
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
