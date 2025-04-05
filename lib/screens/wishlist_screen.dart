import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
      ),
      body: Consumer<ProductsProvider>(builder: (context, provider, child) {
        if (provider.wishlistProducts.isEmpty) {
          return const Center(
              child: Text("No products available in the wishlist"));
        } else {
          return ListView.builder(
              itemCount: provider.wishlistProducts.length,
              itemBuilder: (context, index) {
                final itemId = provider.wishlistProducts[index];
                ProductModel product = provider.getProductById(itemId);
                return ProductTile(item: product);
              });
        }
      }),
    );
  }
}
