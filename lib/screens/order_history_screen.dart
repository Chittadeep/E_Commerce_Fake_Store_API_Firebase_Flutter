import 'package:e_commerce/model/profile_models.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../provider/order_history_provider.dart';

const Color _kBrandBlue = Color(0xFF1A3FBF);

/// Entry point: scopes a fresh OrderHistoryFilterProvider to this screen,
/// the same way CheckoutScreen scopes CheckoutProvider — the widget
/// itself stays a plain StatelessWidget with no local state.
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final filters = context.watch<OrderHistoryFilterProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: _kBrandBlue),
            onPressed: () => Navigator.pop(context), // back to profile/cart context
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final orders = filters.apply(provider.orderHistory);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SearchField(controller: filters.searchController),
              const SizedBox(height: 12),
              _StatusFilterRow(selected: filters.filter, onSelected: filters.selectFilter),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No matching orders.', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                )
              else
                for (final order in orders) ...[
                  _OrderCard(order: order),
                  const SizedBox(height: 16),
                ],
              const SizedBox(height: 8),
              // if (provider.hasMoreOrders)
              //   Center(
              //     child: OutlinedButton(
              //       onPressed: provider.isLoadingMoreOrders ? null : provider.loadMoreOrders,
              //       style: OutlinedButton.styleFrom(
              //         minimumSize: const Size(200, 46),
              //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //       ),
              //       child: provider.isLoadingMoreOrders
              //           ? const SizedBox(
              //         width: 18,
              //         height: 18,
              //         child: CircularProgressIndicator(strokeWidth: 2),
              //       )
              //           : const Text('Load More Orders'),
              //     ),
              //   ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Showing ${provider.orderHistory.length} of ',//${provider.totalOrderCount} orders',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search orders by ID or item...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.selected, required this.onSelected});

  final OrderStatus selected;
  final ValueChanged<OrderStatus> onSelected;

  static const _labels = {
    OrderStatus.all:'All',
    OrderStatus.processing: 'Processing',
    OrderStatus.inTransit: 'In Transit',
    OrderStatus.cancelled: 'Cancelled',
    OrderStatus.delivered: 'Delivered'
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OrderStatus.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = OrderStatus.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(_labels[filter]!),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            selectedColor: _kBrandBlue,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          );
        },
      ),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, dotColor, textColor) = switch (status) {
      OrderStatus.inTransit => ('PROCESSING', const Color(0xFFE3E8FB), _kBrandBlue, _kBrandBlue),
      OrderStatus.all => ('PROCESSING', const Color(0xFFE3E8FB), _kBrandBlue, _kBrandBlue),
      OrderStatus.processing => ('PROCESSING', const Color(0xFFE3E8FB), _kBrandBlue, _kBrandBlue),
      OrderStatus.delivered => ('DELIVERED', const Color(0xFFE3E8FB), _kBrandBlue, _kBrandBlue),
      OrderStatus.cancelled => ('CANCELLED', const Color(0xFFFBE3E7), Colors.redAccent, Colors.redAccent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != OrderStatus.cancelled) ...[
            status == OrderStatus.delivered
                ? Icon(Icons.check_circle, size: 14, color: dotColor)
                : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.3, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER ID: #${order.id}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.status.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isCancelled ? Colors.grey.shade500 : Colors.black87,
            ),
          ),
          Text('Placed on ${timeago.format(order.date)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          _OrderStatusPill(status: order.status),
          const SizedBox(height: 10),
          _OrderPriceRow(order: order),
          const SizedBox(height: 12),
          _OrderItemsRow(order: order),
          const SizedBox(height: 16),
          _OrderActionRow(status: order.status),
        ],
      ),
    );
  }
}

class _OrderPriceRow extends StatelessWidget {
  const _OrderPriceRow({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;

    return Row(
      children: [
        Text(
          '\$${order.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isCancelled ? Colors.grey.shade500 : _kBrandBlue,
            decoration: isCancelled ? TextDecoration.lineThrough : null,
          ),
        )
      ],
    );
  }
}

class _OrderItemsRow extends StatelessWidget {
  const _OrderItemsRow({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.photo,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported_outlined, size: 18, color: Colors.grey),
                ),
              ),
            ),
            // Decorative "more items" hint — order.photo is a single
            // image, so this can't reflect a real item count without a
            // new field; it's purely a visual echo of the mockup's "+".
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text('+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

/// Action buttons vary by status: Track Order/View Details while
/// processing, Buy It Again/View Invoice once delivered, just Contact
/// Support if cancelled.
class _OrderActionRow extends StatelessWidget {
  const _OrderActionRow({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OrderStatus.inTransit: return SizedBox();
      case OrderStatus.all: return SizedBox();
      case OrderStatus.processing:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: navigate to order tracking.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBrandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Track Order'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: navigate to order details.
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        );

      case OrderStatus.delivered:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: re-add this order's items to the cart.
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Buy It Again'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: open/download the invoice.
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Invoice'),
              ),
            ),
          ],
        );

      case OrderStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: open a support/contact flow.
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Contact Support'),
          ),
        );
    }
  }
}