import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/shared/models/group_image.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/services/config_service.dart';
import 'package:frontend/shared/services/group_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupPhotosPage extends StatefulWidget {
  final int groupId;
  const GroupPhotosPage({super.key, required this.groupId});

  @override
  _GroupPhotosPageState createState() => _GroupPhotosPageState();
}

class _GroupPhotosPageState extends State<GroupPhotosPage> {
  late Future<List<GroupImage>> _imagesFuture;
  String baseUrl = ConfigService.baseUrl;
  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _imagesFuture =
          _groupService.fetchGroupImages(user.token, widget.groupId);
    } else {
      _imagesFuture = Future.error(AppLocalizations.of(context)!.userNotLogged);
    }
  }

  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  Future<void> _deleteImage(int imageId) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      return;
    }
    try {
      await _groupService.deleteGroupImage(user.token, imageId);
      setState(() {
        _imagesFuture =
            _groupService.fetchGroupImages(user.token, widget.groupId);
      });
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.imageDeletedSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.imageDeletedFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void selectImages() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      return;
    }
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    } else {
      return;
    }
    try {
      await _groupService.addGroupImages(
        user.token,
        widget.groupId,
        user.id,
        imageFileList,
      );
      setState(() {
        _imagesFuture =
            _groupService.fetchGroupImages(user.token, widget.groupId);
        imageFileList.clear();
      });
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.groupImageSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.groupImageFailure,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.groupPhoto),
      ),
      body: FutureBuilder<List<GroupImage>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text(AppLocalizations.of(context)!.noPhotos));
          } else {
            final images = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Stack(fit: StackFit.expand, children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailPage(image: image),
                        ),
                      );
                    },
                    child: Image.network(
                        Uri.parse("$baseUrl${image.path}").toString(),
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteImage(image.id);
                      },
                    ),
                  ),
                ]);

              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectImages();
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final GroupImage image;
  const ImageDetailPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    String baseUrl = ConfigService.baseUrl;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          Uri.parse("$baseUrl${image.path}").toString(),
        ),
      ),
    );
  }
}
