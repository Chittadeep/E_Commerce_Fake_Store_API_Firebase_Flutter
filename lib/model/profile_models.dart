// lib/model/profile_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus {all, delivered, inTransit, cancelled, processing}

enum AddressTypes {home, work, other}

class SavedAddress {
  SavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.streetAddress,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    this.isDefault = false
  }){
    this.icon = label==AddressTypes.home.toString()?Icons.home:
  label==AddressTypes.work.toString()?Icons.business_outlined:Icons.location_on_outlined;}

  final String id;
  final AddressTypes label;
  final String fullName;
  final String streetAddress;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  bool isDefault;
  IconData? icon;

  /// Formatted full address with line breaks for card views.
  String get formattedAddress {
    final aptStr = apartment != null && apartment!.isNotEmpty ? '$apartment, ' : '';
    return '$streetAddress, $aptStr$city, $state $postalCode, $country';
  }

  /// Single-line address formatting suitable for checkout list items.
  String get formattedAddressSingleLine {
    final aptStr = apartment != null && apartment!.isNotEmpty ? '$apartment, ' : '';
    return '$streetAddress, $aptStr$city, $state $postalCode';
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    final label = AddressTypes.values.byName(json['label']);

    return SavedAddress(
      id: json['id'],
      label: label,
      fullName: json['fullName'],
      streetAddress: json['streetAddress'],
      apartment: json['apartment'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      phone: json['phone'],
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label.name,
    'fullName': fullName,
    'streetAddress': streetAddress,
    'apartment': apartment,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'phone': phone,
    'isDefault': isDefault,
  };

  SavedAddress copyWith(SavedAddress updatedAddress){
    return SavedAddress(id: id, label: updatedAddress.label,
        fullName: updatedAddress.fullName,
        streetAddress: updatedAddress.streetAddress,
        city: updatedAddress.city,
        state: updatedAddress.state,
        postalCode: updatedAddress.postalCode,
        country: updatedAddress.country,
        phone: updatedAddress.phone);
  }

}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.date,
    required this.amount,
    this.title,
    this.photo,
    this.quantity = 1,
    this.statusDetailText = '',
    this.itemsLabel = '',
    this.originalAmount,
    this.noteText,
  });

  final int id;
  final OrderStatus status;
  final DateTime date;
  final double amount;

  // Single-product / legacy fields
  final String? title;
  final String? photo;
  final int quantity;

  // Multi-item / extended status fields
  final String statusDetailText;
  final String itemsLabel;
  final double? originalAmount;
  final String? noteText;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['orderId'],
      status: OrderStatus.values.firstWhere(
            (value) => value.name == json['status'],
        orElse: () => OrderStatus.inTransit,
      ),
      date: json['date'].toDate(),
      amount: json['amount'],
      title: json['title'] as String?,
      photo: json['photo'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      statusDetailText: json['statusDetailText'] as String? ?? '',
      itemsLabel: json['itemsLabel'] as String? ?? '',
      originalAmount: json['originalAmount'],
      noteText: json['noteText'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': id,
    'status': status.name,
    'date': Timestamp.fromDate(date),
    'amount': amount,
    if (title != null) 'title': title,
    if (photo != null) 'photo': photo,
    'quantity': quantity,
    'statusDetailText': statusDetailText,
    'itemsLabel': itemsLabel,
    if (originalAmount != null) 'originalAmount': originalAmount,
    if (noteText != null) 'noteText': noteText,
  };
}