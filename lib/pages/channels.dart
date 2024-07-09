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
class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  DriveHelper? driveHelper;
  FirebaseStorageHelper? firebaseStorageHelper;
  TextEditingController _folderNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<drive.File> folders = [];
  Map<String, String?> recentFiles = {};
  Map<String, String?> recentFileTimes = {};
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

        // Check/Create docStax folder
        await _checkAndCreateDocStaxFolder();
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

  Future<void> _checkAndCreateDocStaxFolder() async {
    if (driveHelper != null) {
      String? docStaxFolderId = await driveHelper!.getFolderIdByName('docStax');

      if (docStaxFolderId == null) {
        docStaxFolderId = await driveHelper!.createFolder('docStax');
      }

      // List folders inside docStax
      folders = await driveHelper!.listFolders(docStaxFolderId);

      // Get the most recent file and profile picture for each folder
      for (var folder in folders) {
        var recentFileData = await driveHelper!.getMostRecentFile(folder.id!);
        if (recentFileData != null) {
          recentFiles[folder.id!] = recentFileData['name'];
          recentFileTimes[folder.id!] = formatDateTime(recentFileData['time']!);
        }

        var profilePictureUrl =
            await firebaseStorageHelper!.getImageUrl(folder.id!);

        profilePictures[folder.id!] = profilePictureUrl;
      }

      setState(() {});
    }
  }


  String formatDateTime(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}";
    }
  }


  Future<void> _createFolderAndUploadImage(
      String folderName, File? imageFile) async {
    if (driveHelper != null) {
      String? docStaxFolderId = await driveHelper!.getFolderIdByName('docStax');
      if (docStaxFolderId == null) {
        docStaxFolderId = await driveHelper!.createFolder('docStax');
      }

      String folderId = await driveHelper!
          .createFolder(folderName, parentFolderId: docStaxFolderId);

      if (imageFile != null) {
        String? imageUrl =
            await firebaseStorageHelper!.uploadImage(imageFile, folderId);
        if (imageUrl != null) {
          profilePictures[folderId] = imageUrl;
        }
      }

      // Refresh folder list and images
      folders = await driveHelper!.listFolders(docStaxFolderId);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Folder "$folderName" created successfully'),
      ));

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create folder'),
      ));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedImageFile = file;
      });

      _openModal();
    }
  }

  Future<dynamic> _openModal() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: selectedImageFile != null
                            ? FileImage(selectedImageFile!)
                            : AssetImage('assets/icons/profile_img.png')
                                as ImageProvider,
                        child: Icon(Icons.add_a_photo),
                      ),
                    ),
                    TextField(
                      controller: _folderNameController,
                      decoration: InputDecoration(
                        labelText: 'Channel Name',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        String folderName = _folderNameController.text.trim();
                        if (folderName.isNotEmpty) {
                          _createFolderAndUploadImage(
                              folderName, selectedImageFile);
                          Navigator.pop(context); // Close the modal
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Please enter a folder name and select an image'),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                            color: const Color.fromARGB(255, 131, 33, 243), width: 2), // Add border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: Add rounded corners
                        ),
                      ),
                      child: Text('Create Channel'),
                    ),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkAndCreateDocStaxFolder,
              child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  print(folder.id);
                  final recentFileName = recentFiles[folder.id] ?? 'No files';
                  final recentFileTime = recentFileTimes[folder.id] ?? '';
                  final profilePictureUrl = profilePictures[folder.id];

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            folder.name ?? 'Unnamed Folder',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          recentFileTimes[folder.id!] ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    subtitle: Text(recentFiles[folder.id!] ?? 'No files'),
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
                            folderId: folder.id!,
                            driveHelper: driveHelper,
                            channelName: folder.name ??
                                'Unnamed Folder', // Pass the channel name
                          ),
                        ),
                      );
                    },

                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(199, 98, 45, 134),
        onPressed: _openModal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
