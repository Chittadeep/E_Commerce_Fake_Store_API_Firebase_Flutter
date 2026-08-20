import 'package:e_commerce/model/profile_models.dart';
import 'package:e_commerce/provider/address_provider.dart';
import 'package:e_commerce/provider/checkout_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:e_commerce/screens/add_address_screen.dart';
import 'package:e_commerce/widgets/shop_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(subtotal: subtotal),
      child: const _CheckoutScreenBody(),
    );
  }
}

class _CheckoutScreenBody extends StatelessWidget {
  const _CheckoutScreenBody();

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'LUMINA',
          style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ShippingAddressSection(),
          SizedBox(height: 16),
          _DeliveryMethodSection(),
          SizedBox(height: 16),
          _PaymentMethodSection(),
          SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: _CheckoutBottomBar(
        total: checkout.total,
        onPlaceOrder: () => checkout.placeOrder(context, context.read<ProductsProvider>()),
      ),
    );
  }
}

/// Small filled circle with a number, used as the "1 / 2 / 3" section
/// marker matching the mockup.
class _SectionNumberBadge extends StatelessWidget {
  const _SectionNumberBadge(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: kBrandBlue,
      child: Text(
        '$number',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

/// Shared card wrapper for each numbered section.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.number, required this.title, required this.child, this.trailing});

  final int number;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionNumberBadge(number),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kBrandBlue, width: 2),
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
      child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
    );
  }
}

class _ShippingAddressSection extends StatelessWidget {
  const _ShippingAddressSection();

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();
    final addresses = context.watch<AddressProvider>().savedAddresses;

    SavedAddress? defaultAddress;
    for (final address in addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }
    checkout.ensureAddressSelected(addresses.map((a) => a.id).toList(), defaultAddress?.id);

    return _SectionCard(
      number: 1,
      title: 'Shipping Address',
      trailing: const Icon(Icons.check_circle_outline, color: Colors.grey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addresses.isEmpty)
            Text('No saved addresses yet.', style: TextStyle(color: Colors.grey.shade600))
          else
            for (final address in addresses) ...[
              _AddressOptionCard(
                address: address,
                isSelected: address.id == checkout.selectedAddressId,
                onTap: () => checkout.selectAddress(address.id),
                onEditTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddAddressScreen(existingAddress: address)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAddressScreen()),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 20, color: kBrandBlue),
                  SizedBox(width: 8),
                  Text('Add New Address', style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEditTap,
  });

  final SavedAddress address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kBrandBlue : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<bool>(value: true, groupValue: isSelected, onChanged: (_) => onTap(), activeColor: kBrandBlue),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        address.isDefault ? '${address.label.name} (Default)' : address.label.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: onEditTap,
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Text(address.fullName, style: const TextStyle(fontSize: 13)),
                  Text(
                    address.formattedAddressSingleLine,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryMethodSection extends StatelessWidget {
  const _DeliveryMethodSection();

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();

    return _SectionCard(
      number: 2,
      title: 'Delivery Method',
      child: Column(
        children: [
          _DeliveryOptionTile(
            title: 'Standard Shipping',
            subtitle: '3-5 business days',
            priceLabel: 'Free',
            isSelected: checkout.deliveryOption == DeliveryOption.standard,
            onTap: () => checkout.selectDelivery(DeliveryOption.standard),
          ),
          const SizedBox(height: 12),
          _DeliveryOptionTile(
            title: 'Express Shipping',
            subtitle: 'Next business day',
            priceLabel: '\$15.00',
            isSelected: checkout.deliveryOption == DeliveryOption.express,
            onTap: () => checkout.selectDelivery(DeliveryOption.express),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  const _DeliveryOptionTile({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kBrandBlue : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: kBrandBlue,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Text(
              priceLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: priceLabel == 'Free' ? kBrandBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection();

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();

    return _SectionCard(
      number: 3,
      title: 'Payment Method',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletOptionButton(
            isSelected: checkout.paymentOption == PaymentOption.applePay,
            onTap: () => checkout.selectPayment(PaymentOption.applePay),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, size: 20),
                SizedBox(width: 8),
                Text('Apple Pay', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _WalletOptionButton(
            isSelected: checkout.paymentOption == PaymentOption.googlePay,
            onTap: () => checkout.selectPayment(PaymentOption.googlePay),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GOOGLE',
                  style: TextStyle(fontWeight: FontWeight.bold, color: kBrandBlue, letterSpacing: 1),
                ),
                SizedBox(width: 8),
                Text('Google Pay', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _WalletOptionButton(
            isSelected: checkout.paymentOption == PaymentOption.razorpay,
            onTap: () => checkout.selectPayment(PaymentOption.razorpay),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card, size: 20, color: kBrandBlue),
                SizedBox(width: 8),
                Text('Razorpay', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR PAY WITH CARD',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Card Number'),
          TextFormField(
            controller: checkout.cardNumberController,
            keyboardType: TextInputType.number,
            onTap: () => checkout.selectPayment(PaymentOption.card),
            decoration: _fieldDecoration(hintText: '0000 0000 0000 0000').copyWith(
              suffixIcon: const Icon(Icons.credit_card_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Expiry Date'),
                    TextFormField(
                      controller: checkout.expiryController,
                      onTap: () => checkout.selectPayment(PaymentOption.card),
                      decoration: _fieldDecoration(hintText: 'MM / YY'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('CVV'),
                    TextFormField(
                      controller: checkout.cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      onTap: () => checkout.selectPayment(PaymentOption.card),
                      decoration: _fieldDecoration(hintText: '123'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(value: checkout.saveCardDetails, onChanged: checkout.setSaveCardDetails),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Save card details for future purchases', style: TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the Apple Pay / Google Pay / Razorpay quick-pay buttons.
class _WalletOptionButton extends StatelessWidget {
  const _WalletOptionButton({required this.isSelected, required this.onTap, required this.child});

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? kBrandBlue : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: child,
      ),
    );
  }
}

/// Sticky Total + Place Order bar pinned to the bottom of the screen.
class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({required this.total, required this.onPlaceOrder});

  final double total;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 15, color: Colors.black87)),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onPlaceOrder,
                child: const Text('Place Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}