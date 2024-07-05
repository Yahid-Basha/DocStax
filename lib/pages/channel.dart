import 'package:docstax/pages/account/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/drive/v2.dart' as drive_v2;
import 'drive/drive_helper.dart';
import './firebase/firebase_storage_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelPage extends StatefulWidget {
  final String folderId;
  final DriveHelper? driveHelper;
  const ChannelPage({required this.folderId,required this.driveHelper, Key? key}) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  
  FirebaseStorageHelper? firebaseStorageHelper;
  List<drive.File> files = [];
  Map<String, bool> uploadingFiles = {};
  Map<String, bool> downloadingFiles = {}; // Define downloadingFiles map
  Map<String, bool> downloadedFiles = {};
  Map<String, String> localFilePaths = {};
  bool _isLoading = true;
  drive_v2.DriveApi? driveApiV2;


  @override
  void initState() {
    super.initState();
    _initializeHelpers();
    _loadDownloadedFiles(); // Load downloaded files on initialization
    _fetchFiles();
  }
  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    setState(() {
      downloadedFiles = {for (var key in keys) key: true};
      localFilePaths = {for (var key in keys) key: prefs.getString(key)!};
    });
  }
  Future<void> _saveDownloadedFile(String fileId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fileId, filePath);
  }
  
  Future<void> _initializeHelpers() async {
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
      final authClient = await getAuthenticatedClient(googleAuth);
      driveApiV2 = drive_v2.DriveApi(authClient);
    }
    firebaseStorageHelper = FirebaseStorageHelper();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedFiles = await widget.driveHelper?.listFiles(widget.folderId) ?? [];
      setState(() {
        files = fetchedFiles;
      });
      print('Fetched files: $files');
    } catch (e) {
      print('Error fetching files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      setState(() {
        uploadingFiles[file.path] = true;
      });

      try {
        await widget.driveHelper?.uploadFile(
            widget.folderId, file.path, file.path.split('/').last);
        _fetchFiles(); // Refresh the file list
      } catch (e) {
        print('Error uploading file: $e');
      } finally {
        setState(() {
          uploadingFiles[file.path] = false;
        });
      }
    }
  }

  Future<void> _downloadFile(drive.File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/${file.name}';
    setState(() {
      downloadingFiles[file.id!] = true;
    });
    try {
      await widget.driveHelper?.downloadFile(file.id!, savePath);
      setState(() {
        downloadingFiles[file.id!] = false;
        downloadedFiles[file.id!] = true;
        localFilePaths[file.id!] = savePath;
      });
      await _saveDownloadedFile(
          file.id!, savePath); // Save to persistent storage

    } catch (e) {
      print('Error downloading file: $e');
      setState(() {
        downloadingFiles[file.id!] = false;
      });
    }
  }


Future<void> _showDeleteModal(drive.File file) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete from device'),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(file, deleteFromCloud: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Delete from cloud'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteFromCloudConfirmation(file);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteFromCloudConfirmation(drive.File file) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete from cloud'),
          content:
              Text('Are you sure you want to delete this file from the cloud?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                _deleteFile(file, deleteFromCloud: true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFile(drive.File file,
      {required bool deleteFromCloud}) async {
    if (deleteFromCloud) {
      try {
        await driveApiV2?.files.trash(file.id!);
        setState(() {
          files.remove(file);
        });
      } catch (e) {
        print('Error deleting file from cloud: $e');
      }
    } else {
      final localPath = localFilePaths[file.id!];
      if (localPath != null) {
        final localFile = File(localPath);
        if (await localFile.exists()) {
          await localFile.delete();
        }
        setState(() {
          downloadedFiles.remove(file.id!);
          localFilePaths.remove(file.id!);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(file.id!);
      }
    }
  }

Widget _buildFileItem(drive.File file, String date) {
    final isUploading = uploadingFiles[file.name] ?? false;
    final isDownloading = downloadingFiles[file.id!] ?? false;
    final isDownloaded = downloadedFiles[file.id!] ?? false;
    final localFilePath = localFilePaths[file.id!];

    // Format the time to show only hours and minutes
    final time =
        file.createdTime?.toLocal().toIso8601String().substring(11, 16) ??
            file.modifiedTime?.toLocal().toIso8601String().substring(11, 16) ??
            'Unknown';

    return Stack(
      children: [
        GestureDetector(
          onTap: () => isDownloaded
              ? OpenFilex.open(localFilePath)
              : _downloadFile(file),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 238, 230, 243),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name ?? 'Unnamed File',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  time,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            children: [
              isDownloading
                  ? CircularProgressIndicator()
                  : isDownloaded
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => OpenFilex.open(localFilePath),
                        )
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadFile(file),
                        ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteModal(file),
              ),
            ],
          ),
        ),
      ],
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? Center(child: Text('No files found.'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Group files by date and reverse the order of the entries
                    ..._groupFilesByDate()
                        .entries
                        .toList()
                        .reversed
                        .map((entry) {
                      final date = entry.key;
                      final filesByDate = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              date,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...filesByDate
                              .map((file) => _buildFileItem(file, date))
                              .toList(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 238, 230, 243),
        onPressed: _pickAndUploadFile,
        child: const Icon(Icons.add),
      ),
    );
  }

Map<String, List<drive.File>> _groupFilesByDate() {
    final Map<String, List<drive.File>> groupedFiles = {};

    for (var file in files) {
      final date =
          file.createdTime?.toLocal().toIso8601String().split('T').first ??
              file.modifiedTime?.toLocal().toIso8601String().split('T').first ??
              'Unknown Date';
      if (groupedFiles[date] == null) {
        groupedFiles[date] = [];
      }
      groupedFiles[date]!.add(file);
    }

    // Reverse the order of each group
    groupedFiles.forEach((key, value) {
      groupedFiles[key] = value.reversed.toList();
    });

    return groupedFiles;
  }


}
