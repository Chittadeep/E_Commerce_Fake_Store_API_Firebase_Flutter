// lib/screens/product_screen.dart
import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/shop_widgets.dart';

class ProductScreen extends StatefulWidget {
  final ProductModel product;
  const ProductScreen(this.product, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // NOTE: ProductModel currently has no `colors` / `sizes` fields, so
  // these are placeholders to match the mockup's layout. Once the model
  // and API carry real variant data, swap these for `widget.product.colors`
  // / `widget.product.sizes` and drop the hardcoded lists below.
  static const _placeholderColors = [Color(0xFF1A3FBF), Color(0xFF10131B), Color(0xFF3E3A33)];
  static const _placeholderSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  int _selectedColorIndex = 0;
  String _selectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final product = widget.product;
    final isInWishlist = provider.wishlistProducts.contains(product.id);
    final isInCart = provider.productsCart.contains(product.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductImageHeader(
                      product: product,
                      isInWishlist: isInWishlist,
                      onWishlistTap: () => provider.tapWishlistProduct(product.id!),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TitleAndRating(product: product),
                          const SizedBox(height: 4),
                          PriceTag(price: product.price ?? 0),
                          const SizedBox(height: 20),
                          const Text('COLOR',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 10),
                          _ColorSwatchRow(
                            colors: _placeholderColors,
                            selectedIndex: _selectedColorIndex,
                            onSelected: (index) => setState(() => _selectedColorIndex = index),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('SELECT SIZE',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              GestureDetector(
                                onTap: () {
                                  // TODO: open a size guide sheet/dialog.
                                },
                                child: const Text(
                                  'Size Guide',
                                  style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _SizeChipRow(
                            sizes: _placeholderSizes,
                            selectedSize: _selectedSize,
                            onSelected: (size) => setState(() => _selectedSize = size),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          _DescriptionExpansion(description: product.description ?? ''),
                          const SizedBox(height: 16),
                          const _DeliveryInfoRow(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionBar(
              isInCart: isInCart,
              isInWishlist: isInWishlist,
              onWishlistTap: () => provider.tapAddToWishlist(product.id!),
              onAddToCartTap: () => provider.tapAddToCart(product.id!),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed product image with a back button and wishlist heart overlaid.
class _ProductImageHeader extends StatelessWidget {
  const _ProductImageHeader({
    required this.product,
    required this.isInWishlist,
    required this.onWishlistTap,
  });

  final ProductModel product;
  final bool isInWishlist;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            product.image ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _CircleIconButton(
            icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
            iconColor: isInWishlist ? Colors.red : kBrandBlue,
            onTap: onWishlistTap,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? Colors.black87, size: 22),
      ),
    );
  }
}

class _TitleAndRating extends StatelessWidget {
  const _TitleAndRating({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.title ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        if (product.rating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(product.rating!.rate!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ColorSwatchRow extends StatelessWidget {
  const _ColorSwatchRow({required this.colors, required this.selectedIndex, required this.onSelected});

  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(colors.length, (index) {
        final isSelected = index == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index],
                border: isSelected ? Border.all(color: kBrandBlue, width: 2) : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SizeChipRow extends StatelessWidget {
  const _SizeChipRow({required this.sizes, required this.selectedSize, required this.onSelected});

  final List<String> sizes;
  final String selectedSize;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: sizes.map((size) {
        final isSelected = size == selectedSize;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelected(size),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? kBrandBlue : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              child: Text(size, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DescriptionExpansion extends StatelessWidget {
  const _DescriptionExpansion({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(description, style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfoRow extends StatelessWidget {
  const _DeliveryInfoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _InfoBox(
            icon: Icons.local_shipping_outlined,
            title: 'Fast Delivery',
            subtitle: '2-4 Business Days',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _InfoBox(
            icon: Icons.assignment_return_outlined,
            title: '30-Day Returns',
            subtitle: 'Easy & Free',
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBrandBlue),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Sticky bottom bar: message/support icon, wishlist toggle, and the
/// primary Add to Cart action.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isInCart,
    required this.isInWishlist,
    required this.onWishlistTap,
    required this.onAddToCartTap,
  });

  final bool isInCart;
  final bool isInWishlist;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _OutlinedIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {
              // TODO: open support/chat.
            },
          ),
          const SizedBox(width: 10),
          _OutlinedIconButton(
            icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
            iconColor: isInWishlist ? Colors.red : Colors.black87,
            onTap: onWishlistTap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onAddToCartTap,
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedIconButton extends StatelessWidget {
  const _OutlinedIconButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Icon(icon, color: iconColor ?? Colors.black87),
      ),
    );
  }
}