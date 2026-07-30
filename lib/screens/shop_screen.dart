// lib/screens/shop_screen.dart
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/widgets/product_tile_shimmer.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/shop_widgets.dart';

/// Full catalog tab's content: search bar, category filter chips, and a
/// product grid. This is the tab body that used to be the whole
/// HomeScreen — renamed since the app now has a separate landing Home tab
/// with its own hero banner, and this no longer owns a Scaffold (MainShell
/// does).
class ShopScreenBody extends StatelessWidget {
  const ShopScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchBar(),
        const _CategoryChipRow(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<ProductsProvider>(
            builder: (context, provider, _) => SectionHeader(
              title: 'New Arrivals',
              trailingText: '${provider.data?.length ?? 0} Items',
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Expanded(child: _ProductGrid()),
      ],
    );
  }
}

/// "Filter & Sort" FAB, shown only while the Shop tab is active. Extracted
/// so MainShell can place it conditionally instead of it living inside a
/// per-tab Scaffold (there's only one Scaffold now, in MainShell).
class ShopFilterFab extends StatelessWidget {
  const ShopFilterFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: open a filter/sort bottom sheet.
      },
      backgroundColor: kBrandBlue,
      icon: const Icon(Icons.tune),
      label: const Text('Filter & Sort'),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}

/// Horizontal category filter chips ("All", "Men", "Women", ...), backed
/// by CategoriesProvider. Selecting a chip re-fetches the product list
/// filtered by that category.
class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.data ?? [];
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = categoryProvider.selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) => _onCategoryTap(context, categoryProvider, category),
                  selectedColor: kBrandBlue,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onCategoryTap(
      BuildContext context,
      CategoriesProvider categoryProvider,
      String category,
      ) {
    final productsProvider = context.read<ProductsProvider>();

    if (categoryProvider.selectedCategory == category) {
      categoryProvider.selectCategory('');
      productsProvider.fetchData();
      return;
    }

    categoryProvider.selectCategory(category);
    productsProvider.fetchDataByCategory(category);
  }
}

/// 2-column grid of products, with a shimmer placeholder while loading
/// and an inline error/empty state otherwise.
class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildGrid(
            itemCount: 6,
            itemBuilder: (context, index) => const ProductTileShimmer(),
          );
        }

        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }

        final products = provider.data;
        if (products == null || products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        return _buildGrid(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isFavorite = provider.wishlistProducts.contains(product.id);
            return ProductGridCard(
              product: product,
              isFavorite: isFavorite,
              onFavoriteTap: () => provider.tapWishlistProduct(product.id!),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductScreen(product)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}