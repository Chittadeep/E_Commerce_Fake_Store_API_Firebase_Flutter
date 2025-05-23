import 'dart:developer';
import 'package:e_commerce/model/product_model.dart';
import 'package:e_commerce/services/products_service.dart';
import 'package:flutter/material.dart';

class ProductsProvider extends ChangeNotifier {
  List<ProductModel>? _data = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel>? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<int> wishlistProducts = [];
  List<int> productsCart = [];

  final ProductsService _productsService = ProductsService();

  ProductsProvider() {
    fetchData();
    fetchWishlist();
  }

  // Method to fetch data from the API
  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _data = await _productsService.fetchData();

    if (data == null) {
      _errorMessage = 'Failed to load products';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDataByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _data = await _productsService.fetchDataByCategory(category);

    if (data == null) {
      _errorMessage = 'Failed to load categorised products';
    }

    _isLoading = false;
    notifyListeners();
  }

  void tapAddToWishlist(int productId) {
    if (wishlistProducts.contains(productId)) {
      wishlistProducts.remove(productId);
      log("added to wishlist");
    } else {
      wishlistProducts.add(productId);
      log("removed from cart");
    }

    _productsService.addToWishlistFirebase(wishlistProducts);
    notifyListeners();
  }

  void tapAddToCart(int productId) {
    if (productsCart.contains(productId)) {
      productsCart.remove(productId);
      log("added to cart");
    } else {
      productsCart.add(productId);
      log("removed from cart");
    }
    _productsService.addToCartFirebase(productsCart);
    notifyListeners();
  }

  ProductModel getProductById(int productId) {
    return data!.where((product) => product.id == productId).single;
  }

  Future<void> fetchWishlist() async {
    wishlistProducts = await _productsService.fetchWishlist();
  }
}
