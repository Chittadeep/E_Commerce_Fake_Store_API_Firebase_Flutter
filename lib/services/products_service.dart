import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductsService {
  Future<List<ProductModel>?> fetchAllProducts() async {
    try {
      List<ProductModel> _data;

      final response =
          await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if (response.statusCode == 200) {
        List<dynamic> t = json.decode(response.body);
        _data = t.map((i) => ProductModel.fromJson(i)).toList();
        return _data;
      } else {
        log('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Failed to load data');
      return null;
    }
  }

  Future<List<ProductModel>?> fetchProductsByCategory(String category) async {
    try {
      List<ProductModel> data;
      final response = await http.get(
          Uri.parse('https://fakestoreapi.com/products/category/$category'));

      if (response.statusCode == 200) {
        List<dynamic> t = json.decode(response.body);
        data = t.map((i) => ProductModel.fromJson(i)).toList();
        return data;
      } else {
        log('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Failed to load data');
      return null;
    }
  }

Future<ProductModel?> fetchProductById(int productId) async {
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products/$productId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> t = json.decode(response.body);
        ProductModel product = ProductModel.fromJson(t);
        return product;
      } else {
        log('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Failed to load data');
      return null;
    }
  }

  Future<void> addToWishlistFirebase(List<int> productIds) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'Wish List': productIds});
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> addToCartFirebase(List<int> productIds) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'Cart': productIds});
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<int>> fetchWishlist() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      log("UID is $uid");
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<dynamic> dynamicList = data['Wish List'] ?? []; // Handle null case
      List<int> wishlist = dynamicList.map((e) => e as int).toList();

      log(wishlist.toString());

      return wishlist;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<List<int>> fetchCart() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      log("UID is $uid");
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<dynamic> dynamicList = data['Cart'] ?? []; // Handle null case
      List<int> cart = dynamicList.map((e) => e as int).toList();

      log(cart.toString());

      return cart;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  }
