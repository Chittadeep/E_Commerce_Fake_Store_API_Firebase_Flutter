import 'package:e_commerce/provider/categories.provider.dart';
import 'package:e_commerce/widgets/categories_drawer.dart';
import 'package:e_commerce/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/products_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Kart'),
      ),
        drawer: const CategoriesDrawer(),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.data.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          return ListView.builder(
            itemCount: provider.data.length,
            itemBuilder: (context, index) {
              final item = provider.data[index];
              return ProductTile(item: item);
            },
          );
        },
      ),
    );
  }
}