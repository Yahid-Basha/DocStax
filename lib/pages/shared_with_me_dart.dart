import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'drive/drive_helper.dart';
import './firebase/firebase_storage_helper.dart';
import 'channel.dart';

class SharedWithMePage extends StatefulWidget {
  const SharedWithMePage({super.key});

  @override
  State<SharedWithMePage> createState() => _SharedWithMePageState();
}

class _SharedWithMePageState extends State<SharedWithMePage> {
  DriveHelper? driveHelper;
  FirebaseStorageHelper? firebaseStorageHelper;
  List<drive.File> sharedFolders = [];
  Map<String, String?> recentFiles = {};
  Map<String, String?> recentFileTimes = {};
  Map<String, String?> profilePictures = {};
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

        // Load shared folders
        await _loadSharedFolders();
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

  Future<void> _loadSharedFolders() async {
    if (driveHelper != null) {
      // List shared folders
      sharedFolders = await driveHelper!.listSharedWithMeFolders();
      // Get the most recent file and profile picture for each folder
      for (var folder in sharedFolders) {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSharedFolders,
              child: ListView.builder(
                itemCount: sharedFolders.length,
                itemBuilder: (context, index) {
                  final folder = sharedFolders[index];
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
        onPressed: () {
          // Implement any required action for FloatingActionButton
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
