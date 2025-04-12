import 'package:e_commerce/provider/auth_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesDrawer extends StatelessWidget {
  const CategoriesDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          getProfileCard(),
          getCategories(),
          ListTile(
            title: const Text("Wishlist"),
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          ListTile(
            title: const Text("Products Cart"),
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signOut(context);
              },
              child: const Text('Logout'))
        ],
      ),
    );
  }

  Widget getProfileCard() {
    return Consumer<ProfileProvider>(
        builder: (context, provider, child) => provider.loading
            ? const CircularProgressIndicator()
            : SizedBox(
                height: 100,
                width: 300,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Card(
                    color: Colors.purple,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircleAvatar(), Text(provider.name ?? '')],
                    ),
                  ),
                ),
              ));
  }

  Widget getCategories() {
    return Consumer<CategoriesProvider>(builder: (context, provider, child) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.errorMessage != null) {
        return const Center(child: Text("No data found"));
      }
      return Expanded(
        child: ListView.builder(
            itemCount: provider.data!.length,
            itemBuilder: (context, index) {
              final item = provider.data![index];
              final isSelected = provider.selectedCategory == item;
              return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black),
                  ),
                  onTap: () {
                    provider.onTapCategory(context, item);
                  });
            }),
      );
    });
  }

}
