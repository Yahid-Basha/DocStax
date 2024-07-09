import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/drive/v2.dart' as drive_v2;
import 'account/auth_helper.dart';
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
  final String channelName; // Add this line

  const ChannelPage({
    required this.folderId,
    required this.driveHelper,
    required this.channelName, // Add this line
    Key? key,
  }) : super(key: key);

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
  List<String> emailList = [];
  String selectedAccessLevel = 'Reader';
  String selectedLinkAccess = 'Restricted';

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
      final fetchedFiles =
          await widget.driveHelper?.listFiles(widget.folderId) ?? [];
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
        await widget.driveHelper
            ?.uploadFile(widget.folderId, file.path, file.path.split('/').last);
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

  Future<void> _showShareModal(drive.File file) async {
    TextEditingController emailController = TextEditingController();
    String fileLink = ''; // Assuming you have a way to get the file link

    showModalBottomSheet(
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
                    Text(
                      'Share "${file.name}"',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Add people, groups, and calendar events',
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            emailList.add(value);
                          });
                          emailController.clear();
                        }
                      },
                    ),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: emailList
                          .map((email) => Chip(
                                label: Text(email),
                                onDeleted: () {
                                  setState(() {
                                    emailList.remove(email);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    DropdownButton<String>(
                      value: selectedAccessLevel,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedAccessLevel = newValue!;
                        });
                      },
                      items: <String>['Reader', 'Commenter', 'Editor']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedLinkAccess,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLinkAccess = newValue!;
                        });
                      },
                      items: <String>['Restricted', 'Anyone with the link']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _updatePermissionsAndCopyLink(file);
                          },
                          child: Text('Copy link'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _updatePermissions(file);
                            Navigator.pop(context); // Close the modal
                          },
                          child: Text('Done'),
                        ),
                      ],
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

  Future<void> _updatePermissionsAndCopyLink(drive.File file) async {
    await _updatePermissions(file);

    String fileLink = await _getFileLink(file.id!);
    _copyToClipboard(fileLink);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Link copied to clipboard'),
    ));
  }

  Future<void> _updatePermissions(drive.File file) async {
    for (var email in emailList) {
      await _addPermission(file, email, selectedAccessLevel.toLowerCase());
    }

    if (selectedLinkAccess == 'Anyone with the link') {
      await _setAnyoneWithLinkPermission(file);
    } else {
      await _setRestrictedPermission(file);
    }
  }

  Future<String> _getFileLink(String fileId) async {
    try {
      var file = await widget.driveHelper!.driveApi.files
          .get(fileId, $fields: 'webViewLink');
      return (file as drive.File).webViewLink ?? '';
    } catch (e) {
      print('Error getting file link: $e');
      return '';
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _addPermission(
      drive.File file, String email, String role) async {
    var permission = drive.Permission()
      ..type = 'user'
      ..role = role
      ..emailAddress = email;

    try {
      await widget.driveHelper!.driveApi.permissions
          .create(permission, file.id!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Permission added successfully'),
      ));
    } catch (e) {
      print('Error adding permission: $e');
    }
  }

  Future<void> _setAnyoneWithLinkPermission(drive.File file) async {
    var permission = drive.Permission()
      ..type = 'anyone'
      ..role = 'reader';

    try {
      await widget.driveHelper!.driveApi.permissions
          .create(permission, file.id!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Link access set to "Anyone with the link"'),
      ));
    } catch (e) {
      print('Error setting link access: $e');
    }
  }

  Future<void> _setRestrictedPermission(drive.File file) async {
    try {
      var permissions =
          await widget.driveHelper!.driveApi.permissions.list(file.id!);
      for (var permission in permissions.permissions!) {
        if (permission.type == 'anyone') {
          await widget.driveHelper!.driveApi.permissions
              .delete(file.id!, permission.id!);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Link access set to "Restricted"'),
      ));
    } catch (e) {
      print('Error setting restricted access: $e');
    }
  }
Widget _buildFileItem(drive.File file, String date) {
    final isUploading = uploadingFiles[file.name] ?? false;
    final isDownloading = downloadingFiles[file.id!] ?? false;
    final isDownloaded = downloadedFiles[file.id!] ?? false;
    final localFilePath = localFilePaths[file.id!];
    final time = _getTimeString(file);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        if (isUploading)
                          const CircularProgressIndicator(strokeWidth: 1.0),
                        if (!isUploading) ...[
                          isDownloading
                              ? CircularProgressIndicator(strokeWidth: 1.0)
                              : isDownloaded
                                  ? IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () =>
                                          OpenFilex.open(localFilePath),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () => _downloadFile(file),
                                    ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _showShareModal(file),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteModal(file),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
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

  String _getTimeString(drive.File file) {
    final now = DateTime.now();
    final createdTime = file.createdTime ?? DateTime.now();
    if (createdTime.year == now.year &&
        createdTime.month == now.month &&
        createdTime.day == now.day) {
      return '${createdTime.hour}:${createdTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${createdTime.day}/${createdTime.month}/${createdTime.year}';
    }
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

    return groupedFiles;
  }
}
