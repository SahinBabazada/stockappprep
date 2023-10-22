import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

class ProductServiceNotifier extends StateNotifier<List<Product>> {
  ProductServiceNotifier() : super([]);

  final product = FirebaseFirestore.instance
      .collection('products')
      .withConverter(fromFirestore: (snapshot, _) {
    return Product.fromJson(snapshot.id, snapshot.data()!);
  }, toFirestore: (model, _) {
    return model.toJson();
  });

  void addProduct(Product model) {
    product.add(model);
  }

  void buyProduct(Product model) {
    product.doc(model.id).update({
      'stockCount': model.stockCount! - 1,
      'stockOut': (model.stockCount! - 1 == 0) ? true : false,
    });
  }

  void deleteProduct(Product model) {
    product.doc(model.id).delete();
  }
}
