import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductTile extends StatelessWidget {
  ProductTile({
    super.key,
    required this.item,
  });

  final ProductModel item;
  Color wishlistedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(item),
        ),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
        child: Image.network(
          item.image!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(item.title!), // Assuming the data has a 'title' field
      subtitle: Text(item.description!),
      trailing: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          bool wishlistContainsProduct =
              provider.wishlistProducts.contains(item.id!);
          return GestureDetector(
            child: Icon(
              Icons.favorite_border,
              color: wishlistContainsProduct ? Colors.red : Colors.grey,
            ),
            onTap: () {
              provider.tapAddToWishlist(item.id!);
            },
          );
        },
      ),
      // Assuming the data has a 'description' field
    );
  }
}
