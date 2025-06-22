import 'dart:developer';

import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/widgets/categories_drawer.dart';
import 'package:e_commerce/widgets/product_tile.dart';
import 'package:e_commerce/widgets/product_tile_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //context.read<ProductsProvider>().fetchData();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Kart'),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
      drawer: const CategoriesDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),

            // Categories Horizontal List
            Consumer<CategoriesProvider>(
              builder: (BuildContext context,
                  CategoriesProvider categoryProvider, _) {
                final List<String> categories = categoryProvider.data ?? [];

                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories?.length,
                    itemBuilder: (BuildContext context, int index) {
                      log(categories.toString());
                      if (categories == null || categories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final String category = categories[index];
                      final bool isSelected =
                          categoryProvider.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (categoryProvider.selectedCategory == category) {
                              categoryProvider.selectCategory("");
                              Provider.of<ProductsProvider>(context,
                                      listen: false)
                                  .fetchData();
                              return;
                            }
                            categoryProvider.selectCategory(category);

                            Provider.of<ProductsProvider>(context,
                                    listen: false)
                                .fetchDataByCategory(category);
                          },
                          selectedColor: theme.primaryColor,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Product Grid
            Expanded(
              child: Consumer<ProductsProvider>(
                builder: (BuildContext context, ProductsProvider provider, _) {
                  if (provider.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GridView.builder(
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2 / 3,
                        ),
                        itemBuilder: (BuildContext context, int index) =>
                            const ProductTileShimmer(),
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  final products = provider.data;
                  if (products == null || products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2 / 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final item = products[index];
                        return ProductTile(item: item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
