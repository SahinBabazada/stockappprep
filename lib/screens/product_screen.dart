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

    String? userEmail;
    userAsyncValue.maybeWhen(
      data: (currentUser) => userEmail = currentUser?.email,
      orElse: () => userEmail = null,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: false,
        centerTitle: true,
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
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('There is some problem for log out')));
                }
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.purpleAccent],
          ),
        ),
        child: Column(
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
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade900, Colors.red.shade600],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.delete,
                              color: Colors.red.shade900, size: 28),
                        ),
                      ),
                      background: Container(
                        color: Colors.transparent,
                      ),
                      key: ValueKey<String>(products[index].id!),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        if (products[index].author != userEmail) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Only the author can delete the product'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return false;
                        }

                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete \'${products[index].name}\'?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        return confirm;
                      },
                      onDismissed: (DismissDirection direction) {
                        productService.deleteProduct(products[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${products[index].name} removed')),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          title: Text(
                            products[index].name ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock: ${products[index].stockCount.toString()}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Author: ${products[index].author ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: (products[index].stockOut == false)
                                ? () async {
                                    final product = products[index];
                                    if (product.stockCount! > 0) {
                                      productService
                                          .buyProduct(products[index]);
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.black38,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Buy'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
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
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        floatingLabelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple.shade100),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        labelStyle: const TextStyle(
                            color:
                                Colors.white), // Style when it's not floating
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white70),
                    onPressed: () {
                      String productName = _productNameController.text.trim();
                      if (productName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product name cannot be empty'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final user = ref.watch(authStateChangesProvider);
                      String? userEmail;
                      user.maybeWhen(
                        data: (currentUser) => userEmail = currentUser?.email,
                        orElse: () => userEmail = null,
                      );

                      if (userEmail != null) {
                        productService.addProduct(Product(
                            name: productName,
                            stockCount: 10,
                            stockOut: false,
                            author: userEmail));
                      }
                      _productNameController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
