import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:image_picker/image_picker.dart';
import 'drive/drive_helper.dart';
import './firebase/firebase_storage_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'channel.dart';

class SharedWithMePage extends StatefulWidget {
  const SharedWithMePage({super.key});

  @override
  State<SharedWithMePage> createState() => _SharedWithMePageState();
}

class _SharedWithMePageState extends State<SharedWithMePage> {
  DriveHelper? driveHelper;
  FirebaseStorageHelper? firebaseStorageHelper;
  TextEditingController _folderNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<drive.File> sharedFiles = [];
  Map<String, String?> recentFiles = {};
  Map<String, String?> profilePictures = {};
  File? selectedImageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDriveHelper();
  }

  Future<void> _initializeDriveHelper() async {
    try {
      final googleUser = await GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/drive.appdata',
          'https://www.googleapis.com/auth/drive.appfolder',
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/drive.resource',
        ],
      ).signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        driveHelper = await DriveHelper.init(googleAuth);
        firebaseStorageHelper = FirebaseStorageHelper();
        print("DriveHelper initialized successfully.");

        // Fetch shared files
        await _fetchSharedFiles();
      } else {
        print("Google authentication failed.");
      }
    } catch (e) {
      print("Error initializing DriveHelper: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSharedFiles() async {
    if (driveHelper != null) {
      sharedFiles = await driveHelper!.listSharedFiles();

      // Get the most recent file and profile picture for each folder
      for (var file in sharedFiles) {
        var recentFile = await driveHelper!.getMostRecentFile(file.id!);
        recentFiles[file.id!] = recentFile?.name;

        var profilePictureUrl =
            await firebaseStorageHelper!.getImageUrl(file.id!);
        profilePictures[file.id!] = profilePictureUrl;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared With Me'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSharedFiles,
              child: ListView.builder(
                itemCount: sharedFiles.length,
                itemBuilder: (context, index) {
                  final file = sharedFiles[index];
                  final recentFileName = recentFiles[file.id] ?? 'No files';
                  final profilePictureUrl = profilePictures[file.id];

                  return ListTile(
                    title: Text(file.name ?? 'Unnamed File'),
                    subtitle: Text(recentFileName),
                    leading: profilePictureUrl != null
                        ? CachedNetworkImage(
                            imageUrl: profilePictureUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.person),
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 28.0,
                              backgroundImage: imageProvider,
                            ),
                          )
                        : CircleAvatar(
                            radius: 28.0,
                            backgroundImage:
                                AssetImage('assets/icons/profile_img.png'),
                            backgroundColor: Colors.transparent,
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChannelPage(
                            folderId: file.id!,
                            driveHelper: driveHelper,
                          ), // Pass the folderId here
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
