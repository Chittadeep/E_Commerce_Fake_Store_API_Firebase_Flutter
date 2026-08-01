// lib/model/profile_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus {all, delivered, inTransit, cancelled, processing}

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
    required this.title,
    required this.photo,
    required this.date,
    required this.amount,
    required this.quantity
  });

  final int id;
  final String title;
  final String photo;
  final OrderStatus status;
  final DateTime date;
  final double amount;
  final int quantity;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'],
      status: OrderStatus.values.firstWhere(
            (value) => value.name == json['status'],
        orElse: () => OrderStatus.inTransit,
      ),
      title: json['title'] as String,
      photo: json['photo'] as String,
      amount: double.parse(json['amount']),
      quantity: json['quantity'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.name,
    'date': date,
    'title': title,
    'photo': photo,
    'amount': amount.toString(),
    'quantity': quantity,
  };
}