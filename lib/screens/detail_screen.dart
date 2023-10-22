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
      body: FutureBuilder(
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
    );
  }
}
