// lib/screens/main_shell.dart
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/screens/cart_screen.dart';
import 'package:e_commerce/screens/edit_profile_screen.dart';
import 'package:e_commerce/screens/home_screen.dart';
import 'package:e_commerce/screens/shop_screen.dart';
import 'package:e_commerce/screens/wishlist_screen.dart';
import 'package:e_commerce/widgets/categories_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/shop_widgets.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabBodies = <Widget>[
    HomeScreenBody(),
    ShopScreenBody(),
    WishlistScreenBody(),
    CartScreenBody(),
    ProfileScreenBody(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<NavigationProvider>().currentTab;

    return Scaffold(
      appBar: _buildAppBar(currentTab),
      drawer: const CategoriesDrawer(),
      floatingActionButton: currentTab == AppTab.shop ? const ShopFilterFab() : null,
      body: SafeArea(
        child: IndexedStack(
          index: currentTab.index,
          children: _tabBodies,
        ),
      ),
      bottomNavigationBar: ShopBottomNavBar(
        currentIndex: currentTab.index,
        onTap: (index) => context.read<NavigationProvider>().setTabByIndex(index),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppTab currentTab) {
    if (currentTab == AppTab.profile) {
      return const ProfileAppBar();
    }
    return const BrandTopBar();
  }
}