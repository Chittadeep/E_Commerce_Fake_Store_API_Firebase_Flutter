import 'dart:convert';

import 'package:e_commerce/model/product_model.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class WishlistProvider extends ChangeNotifier {
  List<ProductModel> products = [];
  bool _isLoading = false;
  String? _errorMessage;


// Method to fetch data from the API
  Future<void> fetchProductsInWishlist(List<int> productsList) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      for (int id in productsList) {
        final response =
            await http.get(Uri.parse('https://fakestoreapi.com/products/$id'));

        if (response.statusCode == 200) {
          ProductModel productModel =
              ProductModel.fromJson(jsonDecode(response.body));

          products.add(productModel);
        } else {
          _errorMessage = 'Error: ${response.statusCode}';
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
