import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/providers.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class ProductScreen extends ConsumerWidget {
  final _productNameController = TextEditingController();

  ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);
    final productService = ref.read(productsServiceProvider.notifier);
    final userAsyncValue = ref.watch(authStateChangesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (userAsyncValue.maybeWhen(
              data: (user) => user != null, orElse: () => false))
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await ref.read(firebaseAuthProvider).signOut();
                  // ignore: use_build_context_synchronously
                  Future.microtask(() => // Use Future.microtask for navigation
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ));
                } catch (e) {
                  print(e);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: products.when(
              data: (products) => ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailScreen(
                                product: products[index],
                              )),
                    );
                  },
                  child: Dismissible(
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    key: ValueKey<String>(products[index].id!),
                    onDismissed: (DismissDirection direction) {
                      productService.deleteProduct(products[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${products[index].name} removed')),
                      );
                    },
                    child: ListTile(
                      title: Text(products[index].name ?? ''),
                      subtitle: Text(products[index].stockCount.toString()),
                      trailing: ElevatedButton(
                        onPressed: (products[index].stockOut == false)
                            ? () async {
                                final product = products[index];
                                if (product.stockCount! > 0) {
                                  productService.buyProduct(products[index]);
                                }
                              }
                            : null,
                        child: const Text('Buy'),
                      ),
                    ),
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) =>
                  const Center(child: Text('An error occurred')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _productNameController,
                    decoration:
                        const InputDecoration(labelText: 'Product Name'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    productService.addProduct(Product(
                        name: _productNameController.text,
                        stockCount: 10,
                        stockOut: false));
                    _productNameController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
