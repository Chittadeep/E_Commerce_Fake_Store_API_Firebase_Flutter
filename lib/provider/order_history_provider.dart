// lib/provider/order_history_filter_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/profile_models.dart';
import 'package:flutter/material.dart';

class OrderHistoryFilterProvider extends ChangeNotifier {
  OrderHistoryFilterProvider() {
    searchController.addListener(notifyListeners);
  }

  final searchController = TextEditingController();
  OrderStatus filter = OrderStatus.all;

  void selectFilter(OrderStatus value) {
    if (value == filter) return;
    filter = value;
    notifyListeners();
  }

  /// Applies the current search text + status filter to [orders].
  List<OrderSummary> apply(List<OrderSummary> orders) {
    final query = searchController.text.trim().toLowerCase();

    return orders.where((order) {
      final matchesFilter = switch (filter) {
        OrderStatus.inTransit =>  true,
        OrderStatus.all => true,
        OrderStatus.processing => order.status == OrderStatus.processing,
        OrderStatus.delivered => order.status == OrderStatus.delivered,
        OrderStatus.cancelled => order.status == OrderStatus.cancelled,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return true; //order.id.toLowerCase().contains(query) || order.itemsLabel.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}