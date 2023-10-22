import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/cloud_storage_service.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CloudStorageService cloudStorage = CloudStorageService();
  late String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade600,
        title: Text(widget.product.name!,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            FutureBuilder(
              future: cloudStorage.downloadURL(widget.product.name!),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple.shade600),
                    strokeWidth: 5.0,
                  );
                } else if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.none ||
                    snapshot.hasError) {
                  return Container(
                    width: 300,
                    height: 300,
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/placeholder.png'), // Use your own placeholder image path.
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return Container(
                  width: 300,
                  height: 300,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data!),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Items Left: ${widget.product.stockCount}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  if (widget.product.author != null)
                    Text(
                      'Created by: ${widget.product.author}',
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.cloud_upload_outlined,
                    color: Colors.white),
                label: const Text("Upload"),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.image,
                  );

                  if (result == null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No file selected')),
                    );
                    return;
                  }

                  final filePath = result.files.single.path!;
                  final fileName = result.files.single.name;

                  String? uploadedImageUrl = await cloudStorage.uploadFile(
                      filePath, widget.product.name!);

                  if (uploadedImageUrl != null) {
                    setState(() {
                      imageUrl =
                          uploadedImageUrl; // Set the new URL to the imageUrl
                    });
                    debugPrint('Upload successful: $uploadedImageUrl');
                  } else {
                    debugPrint('Upload failed');
                  }

                  debugPrint('Path: $filePath');
                  debugPrint('File name: $fileName');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
