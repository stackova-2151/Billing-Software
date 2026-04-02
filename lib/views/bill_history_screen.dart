import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/orders_controller.dart';
import '../models/pos_order.dart';

class BillHistoryScreen extends StatelessWidget {
  const BillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Bill History'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E2E2E),
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _OrderCard(order: order);
          },
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PosOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7ED957).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt,
            color: Color(0xFF7ED957),
          ),
        ),
        title: Text(
          order.id,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFormat.format(order.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentMode == PosPaymentMode.cash
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : const Color(0xFF2563EB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.paymentMode == PosPaymentMode.cash ? 'CASH' : 'ONLINE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: order.paymentMode == PosPaymentMode.cash
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
                if (order.customerName.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    order.customerName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          '₹${order.total.toStringAsFixed(0)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF16A34A),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          ...order.lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.itemName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'x${line.qty}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '₹${line.lineTotal.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Subtotal',
            value: '₹${order.subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 4),
          _SummaryRow(
            label: 'GST (5%)',
            value: '₹${order.gstAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total',
            value: '₹${order.total.toStringAsFixed(0)}',
            emphasis: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: emphasis ? FontWeight.w900 : FontWeight.w700,
              color: emphasis ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: emphasis ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
