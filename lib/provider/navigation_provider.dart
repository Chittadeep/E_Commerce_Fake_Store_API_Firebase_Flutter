// lib/provider/navigation_provider.dart
import 'package:flutter/material.dart';

enum AppTab { home, shop, wishlist, cart, profile }

class NavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.home;

  AppTab get currentTab => _currentTab;
  int get currentIndex => _currentTab.index;

  void setTab(AppTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    notifyListeners();
  }

  void setTabByIndex(int index) => setTab(AppTab.values[index]);
}