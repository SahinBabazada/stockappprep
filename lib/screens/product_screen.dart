// ... (rest of the imports)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../providers/providers.dart';
import 'detail_screen.dart';

class ProductScreen extends ConsumerWidget {
  final TextEditingController _productNameController = TextEditingController();

  ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);
    final productService = ref.read(productsServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          Expanded(
            child: products.when(
              data: (products) =>
                  _buildProductList(context, products, productService),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  const Center(child: Text('An error occurred')),
            ),
          ),
          _buildAddProductField(productService),
        ],
      ),
    );
  }

  Widget _buildProductList(
      BuildContext context, List<Product> products, var productService) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return _buildProductListItem(context, product, productService);
      },
    );
  }

  Widget _buildProductListItem(
      BuildContext context, Product product, var productService) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context, product),
      child: Dismissible(
        background: _buildDismissBackground(Alignment.centerLeft),
        secondaryBackground: _buildDismissBackground(Alignment.centerRight),
        key: ValueKey<String>(product.id!),
        onDismissed: (direction) {
          productService.deleteProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} removed')),
          );
        },
        child: ListTile(
          title: Text(product.name ?? ''),
          subtitle: Text(product.stockCount.toString()),
          trailing: ElevatedButton(
            onPressed: (product.stockOut == false && product.stockCount! > 0)
                ? () => productService.buyProduct(product)
                : null,
            child: const Text('Buy'),
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(product: product),
      ),
    );
  }

  Widget _buildDismissBackground(AlignmentGeometry alignment) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: alignment == Alignment.centerLeft
          ? const EdgeInsets.only(left: 20.0)
          : const EdgeInsets.only(right: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildAddProductField(var productService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_productNameController.text.isNotEmpty) {
                productService.addProduct(Product(
                  name: _productNameController.text,
                  stockCount: 10,
                  stockOut: false,
                ));
                _productNameController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
