import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  ProfileProvider() {
    fetchProfileData();
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
}
