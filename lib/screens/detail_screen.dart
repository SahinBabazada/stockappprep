import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/cloud_storage_service.dart';

// ignore: must_be_immutable
class DetailScreen extends StatefulWidget {
  Product product;
  DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CloudStorageService cloudStorage = CloudStorageService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name!),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: cloudStorage.downloadURL(widget.product.name!),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return SizedBox(
                width: 300,
                height: 300,
                child: Image.network(snapshot.data!),
              );
            },
          ),
          Center(
            child: OutlinedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.image,
                  );

                  if (result == null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No file selected'),
                      ),
                    );
                    return;
                  }
                  final filePath = result.files.single.path!;
                  final fileName = result.files.single.name;

                  cloudStorage
                      .uploadFile(filePath, widget.product.name!)
                      .then((value) => debugPrint('done'));

                  debugPrint('Path: $filePath');
                  debugPrint('File name: $fileName');
                  setState(() {});
                },
                child: const Text('Upload')),
          )
        ],
      ),
    );
  }
}
