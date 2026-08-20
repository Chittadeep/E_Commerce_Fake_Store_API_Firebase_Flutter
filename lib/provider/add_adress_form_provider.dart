// lib/provider/add_address_form_provider.dart
import 'package:e_commerce/model/profile_models.dart';
import 'package:flutter/material.dart';

/// Owns the Add/Edit Address screen's form state. Scoped to that screen
/// only (see AddAddressScreen), not registered app-wide — same reasoning
/// as CheckoutProvider and OrderHistoryFilterProvider: this is transient
/// per-screen state, not data that needs to outlive the screen.
///
/// If [existingAddress] is provided, the form starts pre-filled for
/// editing; otherwise it starts blank for creating a new address.
class AddAddressFormProvider extends ChangeNotifier {
  AddAddressFormProvider({SavedAddress? existingAddress}) : _existingAddress = existingAddress {
    if (existingAddress != null) {
      label = existingAddress.label;
      nameController.text = existingAddress.fullName;
      streetController.text = existingAddress.streetAddress;
      apartmentController.text = existingAddress.apartment ?? '';
      cityController.text = existingAddress.city;
      stateController.text = existingAddress.state;
      postalCodeController.text = existingAddress.postalCode;
      phoneController.text = existingAddress.phone;
      country = existingAddress.country;
    }
  }

  final SavedAddress? _existingAddress;
  bool get isEditing => _existingAddress != null;

  AddressTypes label = AddressTypes.home;

  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final apartmentController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final phoneController = TextEditingController();

  static const countries = ['United States', 'United Kingdom', 'Canada', 'Australia', 'India'];

  String country = 'United States';

  /// Defaults to on, matching the mockup's toggle starting in the "on"
  /// position.
  bool saveForFutureUse = true;

  void selectLabel(String? value) {
    if (value == null || value == label) return;
    label = AddressTypes.values.firstWhere((address)=>address.name==value);
    notifyListeners();
  }

  void selectCountry(String? value) {
    if (value == null || value == country) return;
    country = value;
    notifyListeners();
  }

  void setSaveForFutureUse(bool value) {
    saveForFutureUse = value;
    notifyListeners();
  }

  /// Builds the SavedAddress this form currently represents.
  SavedAddress buildAddress({required String generatedId}) {
    return SavedAddress(
      id: _existingAddress?.id ?? generatedId,
      label: label,
      fullName: nameController.text.trim(),
      streetAddress: streetController.text.trim(),
      apartment: apartmentController.text.trim().isEmpty ? null : apartmentController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      country: country,
      phone: phoneController.text.trim(),
      isDefault: _existingAddress?.isDefault ?? false,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    streetController.dispose();
    apartmentController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}