import 'package:e_commerce/model/profile_models.dart';
import 'package:e_commerce/provider/address_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_address_screen.dart';

const Color _kBrandBlue = Color(0xFF1A3FBF);

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kBrandBlue,
        title: const Text(
          'Saved Addresses',
          style: TextStyle(color: _kBrandBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: _kBrandBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          final addresses = provider.savedAddresses;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (addresses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text('No saved addresses yet.', style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    )
                  else
                    for (final address in addresses) ...[
                      _AddressCard(address: address),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrandBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                    label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final SavedAddress address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(label: address.label),
              const SizedBox(width: 8),
              if (address.isDefault) const _DefaultBadge(),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddAddressScreen(existingAddress: address)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.black87),
                onPressed: () => context.read<AddressProvider>().deleteAddress(address.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            address.formattedAddress,
            style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(address.phone, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => context.read<AddressProvider>().setDefaultAddress(address.id),
              child: Row(
                children: [
                  Icon(Icons.radio_button_off, size: 20, color: Colors.grey.shade500),
                  const SizedBox(width: 10),
                  Text('Set as Default', style: TextStyle(color: Colors.grey.shade800)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final AddressTypes label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFEAF0FB), borderRadius: BorderRadius.circular(20)),
      child: Text(label.name, style: const TextStyle(color: _kBrandBlue, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _kBrandBlue, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text('Default', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}