import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_models.dart';

class AddressService {

  Future<List<SavedAddress>?> fetchSavedAddresses() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      List<SavedAddress> savedAddresses = [];

      final data = doc.data() as Map<String, dynamic>?;
      final rawAddresses = (data?['addresses'] as List<dynamic>?) ?? [];

      savedAddresses = rawAddresses.map((raw) => SavedAddress.fromJson(raw)).toList();
      return savedAddresses;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> persistAddresses(List<SavedAddress> savedAddresses) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'addresses': savedAddresses.map((address)=>address.toJson()).toList()
      });
    } catch (e) {
      log(e.toString());
    }
  }
}