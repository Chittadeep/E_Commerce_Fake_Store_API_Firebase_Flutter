import 'dart:convert';
import 'dart:developer';

import 'package:e_commerce/model/product_model.dart';
import 'package:http/http.dart' as http;

class ProductsService {
  Future<List<ProductModel>?> fetchData() async {
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
}
