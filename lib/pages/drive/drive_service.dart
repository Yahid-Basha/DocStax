import 'package:googleapis/drive/v3.dart' as drive_v3;
import 'package:googleapis/drive/v2.dart' as drive_v2;
import 'package:googleapis_auth/auth_io.dart';

class DriveService {
  final drive_v3.DriveApi apiV3;
  final drive_v2.DriveApi apiV2;

  DriveService(this.apiV3, this.apiV2);

  // Use the v2 API to trash a file
  Future<void> trashFile(String fileId) async {
    try {
      await apiV2.files.trash(fileId);
      print('File trashed successfully.');
    } catch (e) {
      print('Error trashing file: $e');
    }
  }

  // Other v3 API functions...
}
