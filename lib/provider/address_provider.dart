import 'dart:developer';

import 'package:e_commerce/services/AddressService.dart';
import 'package:flutter/foundation.dart';

import '../model/profile_models.dart';

class AddressProvider extends ChangeNotifier {
  List<SavedAddress> savedAddresses = [];

  bool loading = false;
  final AddressService _addressService;

  AddressProvider(this._addressService){
    fetchSavedAddresses();
  }

  Future<void> fetchSavedAddresses() async {
    try {
      loading = true;
      notifyListeners();
      savedAddresses = await _addressService.fetchSavedAddresses()??[];
    } catch (e) {
      log(e.toString());
    } finally {
      loading = false;
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
    await _addressService.persistAddresses(savedAddresses);
  }

  Future<void> updateAddress(SavedAddress updated) async {
    final index = savedAddresses.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    if (updated.isDefault) {
      savedAddresses.where((address)=>address.id==updated.id).first.copyWith(updated);
    } else {
      savedAddresses = [for (final existing in savedAddresses) existing.id == updated.id ? updated : existing];
    }

    notifyListeners();
    await _addressService.persistAddresses(savedAddresses);
  }

  Future<void> deleteAddress(String addressId) async {
    final wasDefault = savedAddresses.any((a) => a.id == addressId && a.isDefault);
    savedAddresses = savedAddresses.where((a) => a.id != addressId).toList();

    if (wasDefault && savedAddresses.isNotEmpty) {
      savedAddresses.removeWhere((address)=>address.id==addressId);
    }

    notifyListeners();
    await _addressService.persistAddresses(savedAddresses);
  }

  Future<void> setDefaultAddress(String addressId) async {
    savedAddresses.where((address)=>address.isDefault).first.isDefault=false;
    savedAddresses.where((address)=>address.id==addressId).first.isDefault=true;
    notifyListeners();
    await _addressService.persistAddresses(savedAddresses);
  }
}