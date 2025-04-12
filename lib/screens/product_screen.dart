import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  final ProductModel product;
  const ProductScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Image.network(
                  product.image!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Product Title
              Text(
                product.title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Product Price
              Text(
                "\$${product.price}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Product Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    "${product.rating?.rate.toString()} (${product.rating?.count} ratings)",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Description
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description!,
                style: const TextStyle(fontSize: 16),
              ),
              Consumer<ProductsProvider>(builder: (context, provider, child) {
                return Column(
                  children: [
                    Center(
                        child: ElevatedButton(
                            onPressed: () {
                              provider.tapAddToCart(product.id!);
                            },
                            child: Text(
                                provider.productsCart.contains(product.id)
                                    ? "Remove from cart"
                                    : "Add to cart"))),
                    Center(
                        child: ElevatedButton(
                            onPressed: () {
                              provider.tapAddToWishlist(product.id!);
                            },
                            child: Text(
                                provider.wishlistProducts.contains(product.id)
                                    ? "Remove from wishlist"
                                    : "Add to wishlist"))),
                  ],
                );
              }),
              Center(child: ElevatedButton(onPressed: () {}, child: const Text("Buy Now")))
            ],
          ),
        ),
      ),
    );
  }
}
