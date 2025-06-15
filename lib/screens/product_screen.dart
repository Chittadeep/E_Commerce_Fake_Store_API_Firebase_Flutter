import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  final ProductModel product;
  const ProductScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    ProductsProvider provider = context.read<ProductsProvider>();
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          product.image!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 30,
                        child: Consumer<ProductsProvider>(
                          builder: (context, provider, child) {
                            bool isInWishlist =
                                provider.wishlistProducts.contains(product.id);
                            return GestureDetector(
                              onTap: () {
                                provider.tapAddToWishlist(product.id!);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isInWishlist ? Colors.red : Colors.grey,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
              Column(children: [
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          provider.tapAddToCart(product.id!);
                        },
                        child: Text(provider.productsCart.contains(product.id)
                            ? "Remove from cart"
                            : "Add to cart"))),
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          provider.openCheckout(
                              name: product.title!,
                              amt: product.price!,
                              description: product.description!);
                        },
                        child: const Text("Buy Now")))
              ])
            ],
          ),
        ),
      ),
    );
  }
}
