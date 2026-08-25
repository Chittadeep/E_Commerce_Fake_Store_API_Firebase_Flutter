import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {

  Future<void> updateWishlistFirebase(List<int> productIds) async {
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

  Future<List<int>> fetchWishlist() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
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
}