import 'package:e_commerce/model/profile_models.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:e_commerce/screens/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _kBrandBlue = Color(0xFF1A3FBF);

/// App bar shown only while the Profile tab is active — different enough
/// from the shared BrandTopBar (plain title instead of the logo/wordmark,
/// a cart shortcut instead of search) that MainShell swaps it in
/// conditionally rather than trying to force one AppBar to cover both.
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black87,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: _kBrandBlue),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text('Edit Profile', style: TextStyle(color: Colors.black87)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: _kBrandBlue),
          onPressed: () => context.read<NavigationProvider>().setTab(AppTab.cart),
        ),
      ],
    );
  }
}

/// Profile tab's content — MainShell provides the Scaffold, the
/// ProfileAppBar above (swapped in conditionally), Drawer, and
/// BottomNavigationBar around this.
class ProfileScreenBody extends StatelessWidget {
  const ProfileScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: provider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _AvatarPicker(provider: provider)),
                const SizedBox(height: 30),
                const _FieldLabel('Full Name'),
                const SizedBox(height: 8),
                _NameField(provider: provider),
                const SizedBox(height: 20),
                const _FieldLabel('Gender'),
                const SizedBox(height: 8),
                _GenderField(provider: provider),
                const SizedBox(height: 20),
                const _FieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _PhoneNumberRow(provider: provider),
                const SizedBox(height: 30),
                _UpdateProfileButton(provider: provider),
                const SizedBox(height: 32),
                const _SectionTitle('Saved Addresses'),
                const SizedBox(height: 12),
                _SavedAddressesList(addresses: provider.savedAddresses),
                const SizedBox(height: 32),
                _SectionTitle(
                  'Order History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shared input decoration for the rounded, filled fields on this screen.
InputDecoration _fieldDecoration({String? hintText, IconData? icon}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: icon != null ? Icon(icon, color: _kBrandBlue) : null,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
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
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

    if (onTap == null) return title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          Icon(Icons.chevron_right, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}

/// Circular avatar with a camera-icon button overlaid for picking a new
/// profile photo.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: provider.imageFile != null ? FileImage(provider.imageFile!) : null,
          child: provider.imageFile == null
              ? const Icon(Icons.person, size: 60, color: Colors.grey)
              : null,
        ),
        Container(
          decoration: BoxDecoration(
            color: _kBrandBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            onPressed: provider.pickImage,
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: provider.nameController,
      decoration: _fieldDecoration(icon: Icons.person_outline),
      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: provider.selectedGender,
      decoration: _fieldDecoration(icon: Icons.people_outline),
      items: provider.genders
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: provider.changeGender,
    );
  }
}

class _PhoneNumberRow extends StatelessWidget {
  const _PhoneNumberRow({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: provider.selectedCountryCode,
            decoration: _fieldDecoration(icon: Icons.phone_outlined),
            items: provider.countryCodes
                .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                .toList(),
            onChanged: provider.changeCountryCode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: provider.phoneController,
            keyboardType: TextInputType.phone,
            decoration: _fieldDecoration(hintText: 'Phone Number'),
            validator: (value) =>
            value == null || value.isEmpty ? 'Please enter your phone number' : null,
          ),
        ),
      ],
    );
  }
}

class _UpdateProfileButton extends StatelessWidget {
  const _UpdateProfileButton({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => provider.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kBrandBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'UPDATE PROFILE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _SavedAddressesList extends StatelessWidget {
  const _SavedAddressesList({required this.addresses});

  final List<SavedAddress> addresses;

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return Text('No saved addresses yet.', style: TextStyle(color: Colors.grey.shade600));
    }

    return Column(
      children: [
        for (final address in addresses) ...[
          _SavedAddressCard(address: address),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SavedAddressCard extends StatelessWidget {
  const _SavedAddressCard({required this.address});

  final SavedAddress address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(address.icon, color: _kBrandBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(address.fullAddress, style: TextStyle(color: Colors.grey.shade700, height: 1.3)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _kBrandBlue, size: 20),
            onPressed: () => context.read<ProfileProvider>().editAddress(context, address),
          ),
        ],
      ),
    );
  }
}