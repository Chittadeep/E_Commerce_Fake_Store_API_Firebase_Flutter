// lib/screens/home_screen.dart
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/shop_widgets.dart';

/// Landing tab's content: hero banner, quick category icons, a "Trending
/// Now" grid, and a newsletter signup card. Product data + favorites all
/// come from ProductsProvider; this widget only lays things out.
///
/// This is a tab body, not a screen — MainShell provides the Scaffold,
/// AppBar, Drawer, and BottomNavigationBar around it.
class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _HeroBanner(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: 'Categories',
            trailingText: 'View All',
            onTrailingTap: () => context.read<NavigationProvider>().setTab(AppTab.shop),
          ),
        ),
        const SizedBox(height: 12),
        const _CategoryIconRow(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(title: 'Trending Now'),
        ),
        const SizedBox(height: 12),
        const _TrendingGrid(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _NewsletterCard(),
        ),
      ],
    );
  }
}

/// "NEW SEASON" hero image with overlay heading and CTA. Copy is static
/// for now — swap for a CMS/remote-config value if this needs to change
/// without a release.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB9BEC7), Color(0xFF2A2E35)],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kBrandBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEW SEASON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Elevated Basics:\nNew Arrivals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.read<NavigationProvider>().setTab(AppTab.shop),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SHOP COLLECTION', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Row of quick-access category icons. `label` doubles as the category
/// value passed on to the Shop screen's filter.
class _CategoryIconRow extends StatelessWidget {
  const _CategoryIconRow();

  static const _categories = [
    (icon: Icons.devices_other_outlined, label: 'Electronics'),
    (icon: Icons.diamond_outlined, label: 'Jewelry'),
    (icon: Icons.male, label: "Men's"),
    (icon: Icons.female, label: "Women's"),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _onCategoryTap(context, category.label),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFF0F3F8),
                    child: Icon(category.icon, color: kBrandBlue),
                  ),
                  const SizedBox(height: 6),
                  Text(category.label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Selects [category] in CategoriesProvider, refetches ProductsProvider
  /// filtered by it, then switches to the Shop tab. Previously this passed
  /// `arguments: category` through `Navigator.pushNamed('/shop', ...)`, but
  /// since Shop is now a tab body rather than a routed screen, filtering
  /// has to happen through the providers directly instead of route args.
  //
  // NOTE: `category` here ("Electronics", "Men's", ...) is a display label,
  // not necessarily the exact category slug the Fake Store API expects
  // (e.g. "men's clothing"). Align these once real category strings are
  // wired up, or map label -> API slug explicitly.
  void _onCategoryTap(BuildContext context, String category) {
    context.read<CategoriesProvider>().selectCategory(category);
    context.read<ProductsProvider>().fetchDataByCategory(category);
    context.read<NavigationProvider>().setTab(AppTab.shop);
  }
}
class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, _) {
        final products = (provider.data ?? []).take(4).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2 / 3,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFavorite = provider.wishlistProducts.contains(product.id);
              return ProductGridCard(
                product: product,
                isFavorite: isFavorite,
                onFavoriteTap: () => provider.tapAddToWishlist(product.id!),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductScreen(product)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// "Join the Inner Circle" email capture card.
/// Hooking the JOIN button up to a mailing-list API is left as a TODO
/// since no such provider/service exists yet.
class _NewsletterCard extends StatefulWidget {
  const _NewsletterCard();

  @override
  State<_NewsletterCard> createState() => _NewsletterCardState();
}

class _NewsletterCardState extends State<_NewsletterCard> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline, color: kBrandBlue, size: 28),
          const SizedBox(height: 10),
          const Text(
            'Join the Inner Circle',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Get exclusive early access to drops and member-only pricing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    filled: true,
                    fillColor: Colors.white,
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
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: wire up to a newsletter/mailing-list service.
                },
                child: const Text('JOIN'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}