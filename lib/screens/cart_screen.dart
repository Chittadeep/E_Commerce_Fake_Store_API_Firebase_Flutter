import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_widgets.dart';
import '../widgets/shop_widgets.dart' hide kBrandBlue;

/// Cart tab's content — MainShell provides the Scaffold, AppBar, and
/// BottomNavigationBar around this.
class CartScreenBody extends StatelessWidget {
  const CartScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        final cartIds = provider.productsCart;
        if (cartIds.isEmpty) {
          return const _EmptyCartState();
        }

        // Group repeated ids into (product, quantity) pairs. Once
        // ProductsProvider tracks quantity directly, replace this with
        // that data instead of counting list occurrences.
        final quantities = <int, int>{};
        for (final id in cartIds) {
          quantities[id] = (quantities[id] ?? 0) + 1;
        }
        final lines = quantities.entries
            .map((entry) => (product: provider.getProductById(entry.key), quantity: entry.value))
            .toList();

        final subtotal = lines.fold<double>(
          0,
              (sum, line) => sum + (line.product.price ?? 0) * line.quantity,
        );
        const tax = 0.0; // TODO: replace with real tax calculation.

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CartHeader(itemCount: cartIds.length, onClearAll: provider.clearCart),
            const SizedBox(height: 16),
            for (final line in lines) ...[
              _CartLineItem(
                product: line.product,
                quantity: line.quantity,
                onIncrement: () => provider.incrementCartItem(line.product.id!),
                onDecrement: () => provider.decrementCartItem(line.product.id!),
                onRemove: () => provider.removeCartItem(line.product.id!),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            _OrderSummaryCard(subtotal: subtotal, tax: tax),
            const SizedBox(height: 24),
            const SectionHeader(title: 'You might also like'),
            const SizedBox(height: 12),
            _RecommendedRow(excludingIds: cartIds.toSet()),
          ],
        );
      },
    );
  }
}

/// Shown instead of the line-item list when the cart has nothing in it:
/// a product-style bag image, heading/subtitle, a "Start Shopping" CTA,
/// and a "Browse by Category" showcase with real category photos.
class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        const SizedBox(height: 24),
        const _EmptyCartImage(),
        const SizedBox(height: 40),
        const Text(
          'Your Cart is Empty',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "Looks like you haven't added anything yet. Start exploring our latest arrivals!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 24),
        const _StartShoppingButton(),
        const SizedBox(height: 28),
        const _BrowseByCategoryHeader(),
        const SizedBox(height: 12),
        const _CategoryShowcaseGrid(),
      ],
    );
  }
}

/// Decorative bag image at the top of the empty state.
///
/// NOTE: this is a placeholder network image, not a bundled asset — swap
/// `_imageUrl` for a real hosted image (or an `Image.asset(...)` once
/// there's a bundled illustration) when one's available.
class _EmptyCartImage extends StatelessWidget {
  const _EmptyCartImage();

  static const _imageUrl =
      'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          _imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade100,
            child: const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

/// Full-width rectangular CTA that switches to the Shop tab.
class _StartShoppingButton extends StatelessWidget {
  const _StartShoppingButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => context.read<NavigationProvider>().setTab(AppTab.shop),
        child: const Text(
          'START SHOPPING',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 15),
        ),
      ),
    );
  }
}

/// "BROWSE BY CATEGORY" label with a trailing divider line.
class _BrowseByCategoryHeader extends StatelessWidget {
  const _BrowseByCategoryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'BROWSE BY CATEGORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

/// 2x2 grid of category photo cards. Tapping one filters ProductsProvider
/// by that category and switches to the Shop tab, same pattern used by
/// the Home screen's category row and the Wishlist empty state.
///
/// These four labels/categories match the Fake Store API's real category
/// slugs (electronics / jewelery / men's clothing / women's clothing), so
/// — unlike the earlier Wishlist empty-state shortcuts (Fashion/Tech/
/// Living/Sport) — no label-to-category mapping guesswork is needed here.
class _CategoryShowcaseGrid extends StatelessWidget {
  const _CategoryShowcaseGrid();

  static const _categories = [
    (label: 'Electronics', category: 'electronics', imageUrl: _electronicsUrl),
    (label: 'Jewelry', category: 'jewelery', imageUrl: _jewelryUrl),
    (label: "Men's", category: "men's clothing", imageUrl: _mensUrl),
    (label: "Women's", category: "women's clothing", imageUrl: _womensUrl),
  ];

  // NOTE: placeholder stock photo URLs — replace with real category
  // imagery (CMS-hosted or bundled assets) once available.
  static const _electronicsUrl =
      'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&q=80';
  static const _jewelryUrl =
      'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600&q=80';
  static const _mensUrl =
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&q=80';
  static const _womensUrl =
      'https://images.unsplash.com/photo-1518310383802-640c2de311b6?w=600&q=80';

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 20,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final entry = _categories[index];
        return _CategoryShowcaseTile(
          label: entry.label,
          imageUrl: entry.imageUrl,
          onTap: () {
            context.read<CategoriesProvider>().selectCategory(entry.category);
            context.read<ProductsProvider>().fetchDataByCategory(entry.category);
            context.read<NavigationProvider>().setTab(AppTab.shop);
          },
        );
      },
    );
  }
}

class _CategoryShowcaseTile extends StatelessWidget {
  const _CategoryShowcaseTile({required this.label, required this.imageUrl, required this.onTap});

  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount, required this.onClearAll});

  final int itemCount;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: 'Cart',
      subtitle: '$itemCount items in your bag',
      trailingText: 'Clear all',
      onTrailingTap: onClearAll,
    );
  }
}

class _CartLineItem extends StatelessWidget {
  const _CartLineItem({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.image ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade100,
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuantityStepper(quantity: quantity, onIncrement: onIncrement, onDecrement: onDecrement),
                    PriceTag(price: (product.price ?? 0) * quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.subtotal, required this.tax});

  final double subtotal;
  final double tax;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
          const _SummaryRow(label: 'Shipping', value: 'FREE', valueColor: kBrandBlue),
          _SummaryRow(label: 'Tax', value: '\$${tax.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total',
            value: '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 16),
          const _PromoCodeField(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // TODO: navigate to / trigger checkout flow.
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Secure Checkout Powered by Lumina',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.isBold = false, this.valueColor});

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: valueColor ?? (isBold ? Colors.black : Colors.grey.shade700),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: isBold ? Colors.black : Colors.grey.shade700)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _PromoCodeField extends StatefulWidget {
  const _PromoCodeField();

  @override
  State<_PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<_PromoCodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Promo Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // TODO: validate/apply the promo code via a discounts service.
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Small recommended-products row, excluding anything already in the cart.
class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({required this.excludingIds});

  final Set<int> excludingIds;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        final recommended = (provider.data ?? [])
            .where((product) => !excludingIds.contains(product.id))
            .take(2)
            .toList();
        if (recommended.isEmpty) return const SizedBox.shrink();

        return Row(
          children: recommended
              .map(
                (product) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductScreen(product)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 6),
                      Text(
                        product.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      PriceTag(price: product.price ?? 0),
                    ],
                  ),
                ),
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }
}
