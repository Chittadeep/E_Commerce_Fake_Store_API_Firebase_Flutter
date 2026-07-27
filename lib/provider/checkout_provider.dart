// lib/provider/checkout_provider.dart
import 'package:e_commerce/provider/products_provider.dart';
import 'package:flutter/material.dart';

enum DeliveryOption { standard, express }

enum PaymentOption { applePay, googlePay, razorpay, card }

/// Holds all state for the checkout flow: shipping address fields,
/// delivery/payment selection, the card sub-form, and the computed total.
/// One instance is created per checkout session (see CheckoutScreen),
/// not registered app-wide, since none of this needs to survive beyond
/// a single checkout.
class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({required this.subtotal});

  /// Subtotal handed in from the cart screen; delivery cost is added on
  /// top of this to produce `total`.
  final double subtotal;

  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  static const countries = ['United States', 'United Kingdom', 'Canada', 'Australia', 'India'];
  static const _expressShippingCost = 15.0;

  String country = 'United States';
  DeliveryOption deliveryOption = DeliveryOption.standard;
  PaymentOption paymentOption = PaymentOption.card;
  bool saveCardDetails = false;

  double get deliveryCost => deliveryOption == DeliveryOption.express ? _expressShippingCost : 0;
  double get total => subtotal + deliveryCost;

  void selectCountry(String? value) {
    if (value == null || value == country) return;
    country = value;
    notifyListeners();
  }

  void selectDelivery(DeliveryOption option) {
    if (option == deliveryOption) return;
    deliveryOption = option;
    notifyListeners();
  }

  void selectPayment(PaymentOption option) {
    if (option == paymentOption) return;
    paymentOption = option;
    notifyListeners();
  }

  void setSaveCardDetails(bool? value) {
    saveCardDetails = value ?? false;
    notifyListeners();
  }

  /// NOTE ON PAYMENT INTEGRATION: only Razorpay actually exists anywhere
  /// in this app (ProductsProvider.openCheckout). Apple Pay / Google Pay
  /// match the mockup visually but aren't wired to a real SDK — picking
  /// either one here shows a snackbar instead of silently pretending to
  /// charge the customer.
  void placeOrder(BuildContext context, ProductsProvider productsProvider) {
    if (paymentOption == PaymentOption.razorpay || paymentOption == PaymentOption.card) {
      productsProvider.openCheckout(
        name: 'Lumina Commerce Order',
        amt: total,
        description: 'Order checkout',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${paymentOption == PaymentOption.applePay ? "Apple Pay" : "Google Pay"} isn\'t connected yet.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }
}