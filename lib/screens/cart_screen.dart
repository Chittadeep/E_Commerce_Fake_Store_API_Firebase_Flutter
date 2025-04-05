import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        if (provider.productsCart.isEmpty) {
          return const Center(
            child: Text("No products available in the product cart"),
          );
        } else {
          return ListView.builder(
              itemCount: provider.productsCart.length,
              itemBuilder: (context, index) {
                final itemId = provider.productsCart[index];
                ProductModel product = provider.getProductById(itemId);
                return ProductTile(item: product);
              });
        }
      },
    ));
  }
}
