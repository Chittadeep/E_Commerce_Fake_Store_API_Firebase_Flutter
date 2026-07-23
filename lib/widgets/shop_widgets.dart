// lib/widgets/shop/shop_widgets.dart
//
// Shared building blocks for the Home, Shop, Product, Cart and Wishlist
// screens, so each screen file only contains what's actually specific to it.
import 'package:e_commerce/model/product_model.dart';
import 'package:flutter/material.dart';

const Color kBrandBlue = Color(0xFF1A3FBF);

/// Top bar shared by Home/Shop/Cart/Wishlist: hamburger (opens the drawer),
/// logo + wordmark, and a search action.
class BrandTopBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandTopBar({super.key, this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      foregroundColor: kBrandBlue,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: kBrandBlue, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Lumina Commerce',
            style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: onSearchTap),
      ],
    );
  }
}

/// A page-level heading row, e.g. "New Arrivals" + "120 Items",
/// or "Your Wishlist" + "Clear All". `trailing` is optional.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTrailingTap,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (trailingText != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingText!,
                  style: const TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ],
    );
  }
}

/// Price text, with an optional strikethrough "was" price for discounts.
/// Pass [wasPrice] only once your data model actually carries a discount.
class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.price, this.wasPrice});

  final double price;
  final double? wasPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: const TextStyle(color: kBrandBlue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (wasPrice != null) ...[
          const SizedBox(width: 6),
          Text(
            '\$${wasPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

/// Product card used in the Shop grid and "Trending Now" sections:
/// image, favorite toggle, category label, title, rating, price.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (product.category != null)
              Text(
                product.category!.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              product.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            if (product.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    product.rating!.rate!.toStringAsFixed(1),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            PriceTag(price: product.price ?? 0),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : kBrandBlue,
          size: 18,
        ),
      ),
    );
  }
}

/// +/- quantity stepper used on cart line items.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: onDecrement,
            visualDensity: VisualDensity.compact,
          ),
          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: onIncrement,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation shared by Home/Shop/Wishlist/Cart/Profile.
/// Purely presentational: it doesn't know about routes or providers,
/// it just reports which index was tapped via [onTap]. The caller
/// (MainShell) decides what a tap actually does.
class ShopBottomNavBar extends StatelessWidget {
  const ShopBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: kBrandBlue,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}