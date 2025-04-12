import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/services/auth_service.dart';
import 'package:e_commerce/services/categories_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesProvider extends ChangeNotifier {
  List<dynamic>? _data = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory; // Track selected category

  List<dynamic>? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  final CategoriesService _categoriesService = CategoriesService();
  final AuthService _authService = AuthService();

  CategoriesProvider() {
    fetchData();
  }

  // Method to fetch data from the API
  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _data = await _categoriesService.fetchData();

    if (data == null) {
      _errorMessage = "Failed to load categories data";
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;

    notifyListeners();
  }

  void onTapCategory(BuildContext context, String item) {
    if (selectedCategory == item) {
      selectCategory("");
      Provider.of<ProductsProvider>(context, listen: false).fetchData();
      return;
    }

    selectCategory(item);
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchDataByCategory(item);
    Navigator.pop(context);
  }


}
