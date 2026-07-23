// lib/widgets/categories_drawer.dart
import 'package:e_commerce/provider/auth_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _kBrandBlue = Color(0xFF1A3FBF);
const Color _kBrandBlueLight = Color(0xFF3B5FE0);

class CategoriesDrawer extends StatelessWidget {
  const CategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 8),
            const _CategoriesSection(),
            const Divider(thickness: 1, height: 1),
            const SizedBox(height: 4),
            const _QuickLinksSection(),
            const Spacer(),
            const Divider(thickness: 1, height: 1),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

/// Gradient header: avatar with a white ring, name + a short subtitle,
/// and a search shortcut. Tapping the avatar/name area switches to the
/// Profile tab; the search icon is a separate hit target.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator(color: _kBrandBlue)),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 12, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kBrandBlue, _kBrandBlueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().setTab(AppTab.profile);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white24,
                          backgroundImage: (provider.photoUrl != null && provider.photoUrl!.isNotEmpty)
                              ? NetworkImage(provider.photoUrl!)
                              : null,
                          child: (provider.photoUrl == null || provider.photoUrl!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name?.isNotEmpty == true ? provider.name! : 'Welcome',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'View & edit profile',
                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _CircleIconButton(
                icon: Icons.search,
                onTap: () {
                  Navigator.pop(context); // close the drawer first
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.category_outlined, color: _kBrandBlue, size: 20),
                SizedBox(width: 10),
                Text(
                  'CATEGORIES',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Expanded(child: _CategoryList()),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: _kBrandBlue));
        }

        if (provider.errorMessage != null) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No categories available'),
          );
        }

        final categories = provider.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = provider.selectedCategory == category;
            return _CategoryTile(
              category: category,
              isSelected: isSelected,
              onTap: () => provider.onTapCategory(context, category),
            );
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.isSelected, required this.onTap});

  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  /// Maps a category name to a representative icon. Falls back to a
  /// generic label icon for anything not recognized, so new categories
  /// from the API don't break this list.
  IconData get _icon {
    final normalized = category.toLowerCase();
    if (normalized.contains('electronic')) return Icons.devices_other_outlined;
    if (normalized.contains('jewel')) return Icons.diamond_outlined;
    if (normalized.contains("women")) return Icons.female;
    if (normalized.contains('men')) return Icons.male;
    return Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? _kBrandBlue.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(_icon, size: 20, color: isSelected ? _kBrandBlue : Colors.grey.shade600),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? _kBrandBlue : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _kBrandBlue, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wishlist / Products Cart shortcuts below the category list, each with
/// a small tinted icon badge and a trailing chevron for tap affordance.
class _QuickLinksSection extends StatelessWidget {
  const _QuickLinksSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          _QuickLinkTile(
            icon: Icons.favorite_border,
            label: 'Wishlist',
            onTap: () {
              Navigator.pop(context);
              context.read<NavigationProvider>().setTab(AppTab.wishlist);
            },
          ),
          _QuickLinkTile(
            icon: Icons.shopping_cart_outlined,
            label: 'Products Cart',
            onTap: () {
              Navigator.pop(context);
              context.read<NavigationProvider>().setTab(AppTab.cart);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kBrandBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: _kBrandBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => context.read<AuthProvider>().signOut(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}