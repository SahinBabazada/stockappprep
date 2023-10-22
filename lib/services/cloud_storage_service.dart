import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as cloud_storage;
import 'package:flutter/material.dart';

class CloudStorageService {
  final cloud_storage.FirebaseStorage storage =
      cloud_storage.FirebaseStorage.instance;

  /// Upload Images
  Future<String?> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await storage.ref('test/$fileName').putFile(file);
      String downloadURL = await storage.ref('test/$fileName').getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint(e.message.toString());
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<String> downloadURL(String fileName) async {
    String downloadFile = await storage.ref('test/$fileName').getDownloadURL();
    return downloadFile;
  }
}
