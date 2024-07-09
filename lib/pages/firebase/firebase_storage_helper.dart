import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File image, String folderId) async {
    try {
      final ref = storage.ref().child('profile_pictures/$folderId.jpg');
      final uploadTask = ref.putFile(image);
      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> getImageUrl(String folderId) async {
    try {
      final ref = storage.ref().child('profile_pictures/$folderId.jpg');
      print('================> Fetching image URL for ref: $ref');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }
}
