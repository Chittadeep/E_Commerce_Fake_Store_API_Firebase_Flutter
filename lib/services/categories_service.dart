import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class CategoriesService {
  Future<List?> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products/categories'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data;
      } else {
        log("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error during fetching categories");
      return null;
    }
  }
}
