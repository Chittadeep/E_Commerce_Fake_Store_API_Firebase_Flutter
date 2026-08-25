// lib/screens/wishlist_screen.dart
import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/provider/cart_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/provider/wishlist_provider.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_widgets.dart' hide kBrandBlue;
import '../widgets/shop_widgets.dart';

/// Wishlist tab's content — MainShell provides the Scaffold, AppBar, and
/// BottomNavigationBar around this.
class WishlistScreenBody extends StatelessWidget {
  const WishlistScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        final wishlistIds = provider.wishlistProducts;
        if (wishlistIds.isEmpty) {
          return const _EmptyWishlistState();
        }

        final products = wishlistIds.map(provider.getProductById).toList();
        final trending = (provider.data ?? [])
            .where((product) => !wishlistIds.contains(product.id))
            .take(4)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionHeader(
              title: 'Your Wishlist',
              subtitle: '${wishlistIds.length} items saved for later',
              trailingText: 'Clear All',
              onTrailingTap: () {
                for (final id in List<int>.from(wishlistIds)) {
                  provider.tapWishlistProduct(id);
                }
              },
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _WishlistCard(
                  product: product,
                  onRemove: () => provider.tapCartProduct(product.id!),
                  onMoveToCart: () {
                    provider.tapCartProduct(product.id!);
                    provider.tapWishlistProduct(product.id!);
                  },
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductScreen(product)),
                  ),
                );
              },
            ),
            if (trending.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'Trending Now'),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trending.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = trending[index];
                    return _TrendingThumbnail(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductScreen(product)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Shown instead of the grid when the wishlist has nothing in it yet:
/// a decorative heart badge, heading/subtitle, an "Explore Shop" CTA, and
/// quick category shortcuts to help someone start browsing.
class _EmptyWishlistState extends StatelessWidget {
  const _EmptyWishlistState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _HeartBadge(),
            const SizedBox(height: 32),
            const Text(
              'Your Wishlist is Empty',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the heart icon on any product to save it for later. '
                  'Your future favorites are just a click away.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 28),
            _ExploreShopButton(),
            const SizedBox(height: 24),
            const _CategoryShortcutGrid(),
          ],
        ),
      ),
    );
  }
}

/// The dashed-circle badge with a heart in the middle and a few
/// decorative stars/sparkles scattered around it, matching the mockup.
class _HeartBadge extends StatelessWidget {
  const _HeartBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _DashedCirclePainter(color: kBrandBlue.withOpacity(0.35)),
          ),
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: kBrandBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.favorite_border, size: 70, color: kBrandBlue),
          const Positioned(top: 6, left: 30, child: _Sparkle(Icons.star, 22, Colors.black26)),
          const Positioned(left: -6, top: 105, child: _Sparkle(Icons.auto_awesome, 18, Colors.black26)),
          const Positioned(bottom: 10, right: 10, child: _Sparkle(Icons.star, 20, Colors.orangeAccent)),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle(this.icon, this.size, this.color);

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}

/// Draws a dashed circle outline. Written by hand instead of pulling in a
/// dotted-border package, since this is the only place that needs one.
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, this.dashCount = 40});

  final Color color;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final sweepPerDash = (2 * 3.14159265) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i.isOdd) continue; // skip every other segment to create the gaps
      final startAngle = i * sweepPerDash;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        startAngle,
        sweepPerDash * 0.6,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashCount != dashCount;
}

/// Full-width pill button that switches to the Shop tab.
class _ExploreShopButton extends StatelessWidget {
  const _ExploreShopButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandBlue,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        onPressed: () => context.read<NavigationProvider>().setTab(AppTab.shop),
        child: const Text(
          'EXPLORE SHOP',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

/// 2x2 grid of quick category shortcuts (Fashion/Tech/Living/Sport).
///
/// NOTE: these four labels are display shortcuts for common categories,
/// not necessarily an exact match for the Fake Store API's category
/// slugs (e.g. "men's clothing" / "women's clothing" / "electronics" /
/// "jewelery" — there's no single "Fashion" or "Living" category there).
/// Map each label to the nearest real category, or replace this list with
/// whatever CategoriesProvider.data actually returns, once that's decided.
class _CategoryShortcutGrid extends StatelessWidget {
  const _CategoryShortcutGrid();

  static const _shortcuts = [
    (icon: Icons.checkroom_outlined, label: 'Fashion', category: "women's clothing"),
    (icon: Icons.devices_other_outlined, label: 'Tech', category: 'electronics'),
    (icon: Icons.house_outlined, label: 'Living', category: 'jewelery'),
    (icon: Icons.fitness_center_outlined, label: 'Sport', category: "men's clothing"),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final shortcut = _shortcuts[index];
        return _CategoryShortcutTile(
          icon: shortcut.icon,
          label: shortcut.label,
          onTap: () {
            context.read<CategoriesProvider>().selectCategory(shortcut.category);
            context.read<ProductsProvider>().fetchDataByCategory(shortcut.category);
            context.read<NavigationProvider>().setTab(AppTab.shop);
          },
        );
      },
    );
  }
}

class _CategoryShortcutTile extends StatelessWidget {
  const _CategoryShortcutTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade800, size: 26),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.product,
  });

  final ProductModel product;

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
                    aspectRatio: 1.3,
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
                  child: GestureDetector(
                    onTap: ()=>cartProvider.tapCartProduct(product.id!),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              product.category ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 6),
            PriceTag(price: product.price ?? 0),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (){
                  cartProvider.tapCartProduct(product.id!);
                  wishlistProvider.tapWishlistProduct(product.id!);
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text('Move to Cart', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingThumbnail extends StatelessWidget {
  const _TrendingThumbnail({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text('\$${(product.price ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: kBrandBlue)),
          ],
        ),
      ),
    );
  }
}