import 'package:e_commerce/provider/auth_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesDrawer extends StatelessWidget {
  const CategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            getProfileCard(context),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.category, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            getCategories(),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text("Wishlist"),
              onTap: () => Navigator.pushNamed(context, '/wishlist'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text("Products Cart"),
              onTap: () => Navigator.pushNamed(context, '/cart'),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().signOut(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getProfileCard(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(provider.photoUrl ?? ''),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    provider.name ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getCategories() {
    return Consumer<CategoriesProvider>(builder: (context, provider, child) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (provider.errorMessage != null) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No categories available"),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: provider.data!.length,
          itemBuilder: (context, index) {
            final item = provider.data![index];
            final isSelected = provider.selectedCategory == item;

            return ListTile(
              leading: Icon(Icons.label,
                  color: isSelected ? Colors.deepPurple : Colors.grey),
              title: Text(
                item,
                style: TextStyle(
                    color: isSelected ? Colors.deepPurple : Colors.black),
              ),
              selected: isSelected,
              selectedTileColor: Colors.deepPurple.shade50,
              onTap: () => provider.onTapCategory(context, item),
            );
          },
        ),
      );
    });
  }
}
