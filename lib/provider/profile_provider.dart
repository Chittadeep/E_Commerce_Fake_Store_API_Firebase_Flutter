import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? photoUrl;

  bool loading = false;

  ProfileProvider() {
    fetchProfileData();
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
      log(email ?? 'No email found');
      log(name ?? 'No name found');
      log(photoUrl ?? 'No photo Url found');
    } catch (e) {
      log(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
