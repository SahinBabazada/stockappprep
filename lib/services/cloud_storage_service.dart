import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as cloud_storage;
import 'package:flutter/material.dart';

class CloudStorageService {
  final cloud_storage.FirebaseStorage storage =
      cloud_storage.FirebaseStorage.instance;

  /// Upload Images
  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await storage.ref('test/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      debugPrint(e.message.toString());
    }
  }

  // /// Uploaded Images List
  // Future<cloud_storage.ListResult> listOfFiles() async {
  //   cloud_storage.ListResult result = await storage.ref('test').listAll();

  //   for (var reference in result.items) {
  //     debugPrint('Found File: $reference');
  //   }
  //   return result;
  // }

  /// DownloadURL Images
  Future<String> downloadURL(String fileName) async {
    String downloadFile = await storage.ref('test/$fileName').getDownloadURL();
    return downloadFile;
  }
}
