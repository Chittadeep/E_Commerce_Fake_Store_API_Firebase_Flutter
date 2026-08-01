import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/profile_models.dart';
import '../screens/edit_profile_screen.dart';

class ProfileProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? photoUrl;
  String? phone;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;

  String selectedGender = 'Male';
  String selectedCountryCode = '+91';
  File? imageFile;

  final genders = ['Male', 'Female', 'Other'];
  final countryCodes = ['+91', '+1', '+44', '+61', '+81'];

  List<SavedAddress> savedAddresses = [];
  List<OrderSummary> orderHistory = [];

  ProfileProvider() {
    fetchProfileData();
    fetchSavedAddresses();
    fetchOrderHistory();
  }

  void pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  void changeGender(String? value) {
    selectedGender = value!;
    notifyListeners();
  }

  void changeCountryCode(String? value) {
    selectedCountryCode = value!;
    notifyListeners();
  }

  void submit(BuildContext context) {
    if (formKey.currentState!.validate()) {
      // Example: Log or save the data
      debugPrint('Name: ${nameController.text}');
      debugPrint('Gender: $selectedGender');
      debugPrint('Phone: $selectedCountryCode ${phoneController.text}');
      debugPrint('Image: ${imageFile?.path}');
      saveProfileData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated')),
      );
    }
  }

  Future<void> fetchProfileData() async {
    try {
      loading = true;
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      log("UID is $uid");
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      email = data['email'];
      name = data['name'];
      photoUrl = data['photoURL'];
      phone = data['phone'];

      selectedGender = data['gender'] ?? 'Male';
      selectedCountryCode = data['countryCode'] ?? '+91';

      log(email ?? 'No email found');
      log(name ?? 'No name found');
      log(photoUrl ?? 'No photo Url found');

      nameController.text = name ?? '';
      phoneController.text = phone ?? '';
    } catch (e) {
      log(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfileData() async {
    try {
      loading = true;
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      log("UID is $uid");

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'countryCode': selectedCountryCode,
        'phone': phoneController.text,
        'name': nameController.text,
        'gender': selectedGender
      });
    } catch (e) {
      log(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Reads the user's saved addresses from Firestore.
  /// Expected shape on the user doc:
  ///   'addresses': [ {'label': 'Home', 'fullAddress': '123 Maple Ave...'}, ... ]
  Future<void> fetchSavedAddresses() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final data = doc.data() as Map<String, dynamic>?;
      final rawAddresses = (data?['addresses'] as List<dynamic>?) ?? [];

      savedAddresses = rawAddresses.map((raw) {
        final map = raw as Map<String, dynamic>;
        final label = map['label'] as String? ?? '';
        return SavedAddress(
          label: label,
          icon: _iconForAddressLabel(label),
          fullAddress: map['fullAddress'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      log(e.toString());
    } finally {
      notifyListeners();
    }
  }

  IconData _iconForAddressLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.business_center_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  /// Prompts for an updated address via a dialog, then persists the full
  /// address list back to Firestore. Takes `context` (like `submit`
  /// already does) since showing the edit dialog needs one.
  Future<void> editAddress(BuildContext context, SavedAddress address) async {
    final controller = TextEditingController(text: address.fullAddress);

    final updatedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${address.label} Address'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedText == null || updatedText.trim().isEmpty) return;

    final index = savedAddresses.indexWhere((a) => a.label == address.label);
    if (index == -1) return;

    savedAddresses[index] = SavedAddress(
      label: address.label,
      icon: address.icon,
      fullAddress: updatedText.trim(),
    );
    notifyListeners();

    await _persistAddresses();
  }

  Future<void> _persistAddresses() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'addresses': savedAddresses
            .map((a) => {'label': a.label, 'fullAddress': a.fullAddress})
            .toList(),
      });
    } catch (e) {
      log(e.toString());
    }
  }

  /// Reads order history from a `users/{uid}/orders` subcollection.
  /// Expected fields per order doc: orderId, status ('delivered' or
  /// anything else treated as in-transit), date, amount.
  Future<void> fetchOrderHistory() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String uid = preferences.get('uid') as String;

      DocumentSnapshot<Map<String, dynamic>> doc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        log((doc.data()?['Orders']).toString());
        final orders = doc.data()?['Orders'] as List<dynamic>? ?? [];

        orderHistory = orders.map((orderSummary)
        => OrderSummary.fromJson(orderSummary)).toList();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      notifyListeners();
    }
  }
}