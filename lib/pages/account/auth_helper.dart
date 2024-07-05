import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

Future<AuthClient> getAuthenticatedClient(
    GoogleSignInAuthentication googleAuth) async {
  final AccessCredentials credentials = AccessCredentials(
    AccessToken(
      'Bearer',
      googleAuth.accessToken!,
      DateTime.now().toUtc().add(Duration(hours: 1)), // Ensure UTC format
    ),
    null, // No refresh token available
    [
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive.appfolder',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.resource',
    ],
  );

  return authenticatedClient(http.Client(), credentials);
}
