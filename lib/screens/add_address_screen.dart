import 'package:e_commerce/model/profile_models.dart';
import 'package:e_commerce/provider/address_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/add_adress_form_provider.dart';

const Color _kBrandBlue = Color(0xFF1A3FBF);

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key, this.existingAddress});

  final SavedAddress? existingAddress;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddAddressFormProvider(existingAddress: existingAddress),
      child: const _AddAddressScreenBody(),
    );
  }
}

class _AddAddressScreenBody extends StatelessWidget {
  const _AddAddressScreenBody();

  @override
  Widget build(BuildContext context) {
    final form = context.watch<AddAddressFormProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kBrandBlue,
        title: Text(
          form.isEditing ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(color: _kBrandBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Address Label'),
                Consumer<AddAddressFormProvider>(builder: (context, value, child) =>
                  DropdownButtonFormField<String>(
                    initialValue: value.label.name,
                    decoration: _fieldDecoration(null),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                    items: AddressTypes.values
                        .map((l) => DropdownMenuItem<String>(
                      value: l.name,
                      child: Row(
                        children: [
                          Icon(
                            l == 'Home'
                                ? Icons.home_outlined
                                : l == 'Office'
                                ? Icons.business_outlined
                                : Icons.location_on_outlined,
                            size: 18,
                            color: _kBrandBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(l.name),
                        ],
                      ),
                    ))
                        .toList(),
                    onChanged: form.selectLabel,

                  ),
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Full Name'),
                TextFormField(controller: form.nameController, decoration: _fieldDecoration('Enter your full name')),
                const SizedBox(height: 18),
                const _FieldLabel('Street Address'),
                TextFormField(controller: form.streetController, decoration: _fieldDecoration('123 Luxury Lane')),
                const SizedBox(height: 18),
                const _FieldLabel('Apartment, Suite, etc. (optional)'),
                TextFormField(controller: form.apartmentController, decoration: _fieldDecoration('Apt 4B')),
                const SizedBox(height: 18),
                const _FieldLabel('City'),
                TextFormField(controller: form.cityController, decoration: _fieldDecoration('San Francisco')),
                const SizedBox(height: 18),
                const _FieldLabel('State / Province'),
                TextFormField(controller: form.stateController, decoration: _fieldDecoration('California')),
                const SizedBox(height: 18),
                const _FieldLabel('Postal Code'),
                TextFormField(
                  controller: form.postalCodeController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('94103'),
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Country'),
                DropdownButtonFormField<String>(
                  value: form.country,
                  decoration: _fieldDecoration(null),
                  items: AddAddressFormProvider.countries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: form.selectCountry,
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Phone Number'),
                TextFormField(
                  controller: form.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration('+1 (555) 000-0000'),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Save this address for future use',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "We'll remember this for your next checkout.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: form.saveForFutureUse,
                      onChanged: form.setSaveForFutureUse,
                      activeColor: _kBrandBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _onSaveAddress(context, form),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      form.isEditing ? 'Save Changes' : 'Save Address',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _DecorativeBuildingImage(),
        ],
      ),
    );
  }

  void _onSaveAddress(BuildContext context, AddAddressFormProvider form) {
    final addressProvider = context.read<AddressProvider>();
    final generatedId = DateTime.now().microsecondsSinceEpoch.toString();
    final address = form.buildAddress(generatedId: generatedId);

    if (form.isEditing) {
      addressProvider.updateAddress(address);
    } else {
      addressProvider.addAddress(address);
    }

    Navigator.pop(context);
  }
}

InputDecoration _fieldDecoration(String? hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kBrandBlue, width: 2),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

class _DecorativeBuildingImage extends StatelessWidget {
  const _DecorativeBuildingImage();

  static const _imageUrl =
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: 0.6,
        child: Image.network(
          _imageUrl,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          color: Colors.grey.shade400,
          colorBlendMode: BlendMode.saturation,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 160,
            color: Colors.grey.shade100,
            child: const Icon(Icons.apartment_outlined, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}