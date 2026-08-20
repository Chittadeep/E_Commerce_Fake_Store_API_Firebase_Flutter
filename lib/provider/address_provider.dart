import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/services/AddressService.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_models.dart';

class AddressProvider extends ChangeNotifier {
  List<SavedAddress> savedAddresses = [];

  final AddressService _addressService;

  AddressProvider(this._addressService){
    fetchSavedAddresses();
  }

  Future<void> fetchSavedAddresses() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final data = doc.data() as Map<String, dynamic>?;
      final rawAddresses = (data?['addresses'] as List<dynamic>?) ?? [];

      savedAddresses = rawAddresses.map((raw) => SavedAddress.fromJson(raw)).toList();
    } catch (e) {
      log(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> addAddress(SavedAddress address) async {
    final shouldBeDefault = address.isDefault || savedAddresses.isEmpty;
    //final newAddress = address.copyWith(isDefault: shouldBeDefault);

    if (shouldBeDefault) {
      savedAddresses.add(address);
    } else {
      savedAddresses = [...savedAddresses, address];
    }

    notifyListeners();
    await _persistAddresses();
  }

  /// Replaces an existing address (matched by id) with [updated], used
  /// by the Add Address screen's edit mode.
  Future<void> updateAddress(SavedAddress updated) async {
    final index = savedAddresses.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    // if (updated.isDefault) {
    //   savedAddresses.where((address).a)
    //     // for (final existing in savedAddresses)
    //     //   existing.id == updated.id ? updated : existing.copyWith(isDefault: false),
    // } else {
    //   savedAddresses = [for (final existing in savedAddresses) existing.id == updated.id ? updated : existing];
    // }

    notifyListeners();
    await _persistAddresses();
  }

  /// Deletes the address with [addressId]. If it was the default and
  /// other addresses remain, the first remaining one becomes the new
  /// default (mirrors addAddress's "never end up with zero defaults"
  /// rule).
  Future<void> deleteAddress(String addressId) async {
    final wasDefault = savedAddresses.any((a) => a.id == addressId && a.isDefault);
    savedAddresses = savedAddresses.where((a) => a.id != addressId).toList();

    if (wasDefault && savedAddresses.isNotEmpty) {
      savedAddresses.removeWhere((address)=>address.id==addressId);
    }

    notifyListeners();
    await _persistAddresses();
  }

  /// Marks [addressId] as the default, unmarking whichever address was
  /// previously the default.
  Future<void> setDefaultAddress(String addressId) async {
    savedAddresses.where((address)=>address.isDefault).first.isDefault=false;
    savedAddresses.where((address)=>address.id==addressId).first.isDefault=true;
    notifyListeners();
    await _persistAddresses();
  }

  Future<void> _persistAddresses() async {
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