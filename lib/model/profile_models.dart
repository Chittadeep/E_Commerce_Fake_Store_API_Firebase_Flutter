// lib/model/profile_models.dart
import 'package:flutter/material.dart';

enum OrderStatus { delivered, inTransit }

class SavedAddress {
  const SavedAddress({
    required this.label,
    required this.icon,
    required this.fullAddress,
  });

  final String label;
  final IconData icon;
  final String fullAddress;
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.date,
    required this.amount,
  });

  final String id;
  final OrderStatus status;
  final String date;
  final double amount;
}