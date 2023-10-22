import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/firestore_services.dart';

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>(
  (ref) {
    var stream = FirebaseFirestore.instance.collection('products').snapshots();

    return stream.map((snapshot) => snapshot.docs
        .map((doc) => Product.fromJson(doc.id, doc.data()))
        .toList());
  },
);

final productsServiceProvider =
    StateNotifierProvider<ProductServiceNotifier, List<Product>>(
        (ref) => ProductServiceNotifier());

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
