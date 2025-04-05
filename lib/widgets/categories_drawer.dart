import 'package:e_commerce/provider/auth_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CategoriesDrawer extends StatelessWidget {
  const CategoriesDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<CategoriesProvider>(builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return const Center(child: Text("No data found"));
        }

        return Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: provider.data.length,
                    itemBuilder: (context, index) {
                      final item = provider.data[index];
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
              ),
              ListTile(
                title: const Text("Wishlist"),
                onTap: () => Navigator.pushNamed(context, '/wishlist'),
              ),
              const ListTile(
                title: Text("Products Cart"),
              ),
              ElevatedButton(
                  onPressed: () {
                    context.read<AuthProvider>().signOut();
                  },
                  child: const Text('Logout'))
            ],
          ),
        );
      }),
    );
  }
}
