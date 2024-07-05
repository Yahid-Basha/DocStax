import 'package:googleapis/drive/v3.dart' as drive;
import '../account/auth_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DriveHelper {
  final drive.DriveApi driveApi;

  DriveHelper(this.driveApi);

  static Future<DriveHelper> init(GoogleSignInAuthentication googleAuth) async {
    final authClient = await getAuthenticatedClient(googleAuth);
    return DriveHelper(drive.DriveApi(authClient));
  }

  Future<String?> getFolderIdByName(String folderName) async {
    try {
      final query =
          "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
      final fileList = await driveApi.files.list(q: query);
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (e) {
      print('Error getting folder ID: $e');
    }
    return null;
  }

  Future<String> createFolder(String folderName,
      {String? parentFolderId}) async {
    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    if (parentFolderId != null) {
      folder.parents = [parentFolderId];
    }

    try {
      final result = await driveApi.files.create(folder);
      print('Folder ID: ${result.id}');
      return result.id!;
    } catch (e) {
      print('Error creating folder: $e');
      rethrow;
    }
  }

  Future<List<drive.File>> listFolders(String parentFolderId) async {
    try {
      final query =
          "'$parentFolderId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await driveApi.files.list(q: query);
      return fileList.files ?? [];
    } catch (e) {
      print('Error listing folders: $e');
      return [];
    }
  }
  
  Future<List<drive.File>> listFilesN(String parentFolderId) async {
    try {
      final query =
          "'$parentFolderId' in parents and mimeType!='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await driveApi.files.list(q: query);
      return fileList.files ?? [];
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  Future<drive.File?> getMostRecentFileB(String parentFolderId) async {
    try {
      final query =
          "'$parentFolderId' in parents and mimeType!='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await driveApi.files
          .list(q: query, orderBy: 'createdTime desc', pageSize: 1);
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first;
      }
    } catch (e) {
      print('Error getting most recent file: $e');
    }
    return null;
  }

  Future<String?> getProfilePictureUrl(String parentFolderId) async {
    try {
      final query =
          "'$parentFolderId' in parents and name='dp.jpg' and trashed=false";
      final fileList = await driveApi.files.list(q: query);
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final file = fileList.files!.first;
        return file.thumbnailLink;
      }
    } catch (e) {
      print('Error getting profile picture: $e');
    }
    return null;
  }

  Future<void> downloadFileB(String fileId, String savePath) async {
    try {
      final response = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final dataStore = File(savePath).openSync(mode: FileMode.write);
      response.stream.listen((data) {
        dataStore.writeFromSync(data);
      }, onDone: () {
        dataStore.close();
        print('File downloaded to $savePath');
      }, onError: (e) {
        print('Error downloading file: $e');
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  

  Future<void> uploadFile(
      String folderId, String filePath, String fileName) async {
    final file = drive.File()
      ..name = fileName
      ..parents = [folderId];

    final media = drive.Media(
      (await http.MultipartFile.fromPath('file', filePath)).finalize(),
      await File(filePath).length(),
    );

    try {
      final result = await driveApi.files.create(file, uploadMedia: media);
      print('Uploaded File ID: ${result.id}');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }


  Future<List<drive.File>> listFilesC(String folderId) async {
    final fileList = await driveApi.files.list(
      q: "'$folderId' in parents and trashed = false",
      $fields: "files(id, name, createdTime, modifiedTime)",
    );
    return fileList.files ?? [];
  }

  Future<void> downloadFileC(String fileId, String savePath) async {
    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final dataStore = File(savePath).openSync(mode: FileMode.write);
    response.stream.listen((data) {
      dataStore.writeFromSync(data);
    }, onDone: () {
      dataStore.close();
    }, onError: (e) {
      print('Error downloading file: $e');
    });
  }

  Future<drive.File?> getMostRecentFileC(String folderId) async {
    final fileList = await driveApi.files.list(
      q: "'$folderId' in parents and trashed = false",
      orderBy: "createdTime desc",
      pageSize: 1,
      $fields: "files(id, name, createdTime, modifiedTime)",
    );
    return fileList.files?.first;
  }

  Future<List<drive.File>> listFiles(String folderId) async {
    final fileList = await driveApi.files.list(
      q: "'$folderId' in parents and trashed = false",
      $fields: "files(id, name, createdTime, modifiedTime)",
    );
    return fileList.files ?? [];
  }

  Future<List<drive.File>> listSharedFiles() async {
    final fileList = await driveApi.files.list(
      q: "sharedWithMe",
      $fields: "files(id, name, createdTime, modifiedTime)",
    );
    return fileList.files ?? [];
  }

  Future<void> downloadFile(String fileId, String savePath) async {
    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final dataStore = File(savePath).openSync(mode: FileMode.write);
    response.stream.listen((data) {
      dataStore.writeFromSync(data);
    }, onDone: () {
      dataStore.close();
    }, onError: (e) {
      print('Error downloading file: $e');
    });
  }

  Future<drive.File?> getMostRecentFile(String folderId) async {
    final fileList = await driveApi.files.list(
      q: "'$folderId' in parents and trashed = false",
      orderBy: "createdTime desc",
      pageSize: 1,
      $fields: "files(id, name, createdTime, modifiedTime)",
    );
    return fileList.files?.first;
  }
}
