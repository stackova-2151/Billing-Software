import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/cart_controller.dart';
import '../models/pos_order.dart';
import '../services/bluetooth_print_service.dart';

class CheckoutScreen extends StatelessWidget {
  final CartController cartController;

  const CheckoutScreen({super.key, required this.cartController});

  // ── Web: PDF bill via printing package ──────────────────────────────────
  Future<void> _printWeb(BuildContext context) async {
    final pdf = pw.Document();
    final lines = cartController.cartLines;
    final subtotal = cartController.subtotal;
    final gst = cartController.gstAmount;
    final total = cartController.total;

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll57,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text('Bill Receipt',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Divider(),
          ...lines.map((l) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${l.item.name} x${l.qty.value}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('₹${l.lineTotal.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              )),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Subtotal', style: pw.TextStyle(fontSize: 10)),
            pw.Text('₹${subtotal.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
          ]),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('GST (5%)', style: pw.TextStyle(fontSize: 10)),
            pw.Text('₹${gst.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
          ]),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('₹${total.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Text('Thank you!', style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    ));

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Bill_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
  }

  // ── Android: Bluetooth thermal printer ──────────────────────────────────
  Future<void> _printAndroid(BuildContext context) async {
    final service = BluetoothPrintService();

    final granted = await service.requestPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permissions are required to print.')),
      );
      return;
    }

    String? mac = await service.getSavedMac();

    if (mac == null) {
      mac = await _showPrinterPicker(context, service);
      if (mac == null) return;
      await service.savePrinterMac(mac);
    }

    final connected = await service.connect(mac);
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to printer. Make sure it is paired and on.')),
      );
      return;
    }

    final order = PosOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      lines: cartController.cartLines
          .map((l) => PosOrderLine(
                itemId: l.item.id,
                itemName: l.item.name,
                qty: l.qty.value,
                unitPrice: l.item.price,
              ))
          .toList(),
      subtotal: cartController.subtotal,
      gstAmount: cartController.gstAmount,
      total: cartController.total,
      paymentMode: cartController.paymentMode.value == 'CASH'
          ? PosPaymentMode.cash
          : PosPaymentMode.online,
    );

    final success = await service.printBill(order, 'My Shop');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Bill printed!' : 'Print failed. Try again.')),
    );
  }

  Future<String?> _showPrinterPicker(BuildContext context, BluetoothPrintService service) async {
    final devices = await service.getPairedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No paired Bluetooth devices found. Pair your printer in Settings first.')),
      );
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Printer'),
        children: devices
            .map((d) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, d.macAdress),
                  child: Text('${d.name}\n${d.macAdress}',
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
      ),
    );
  }

  void _onPrint(BuildContext context) {
    if (kIsWeb) {
      _printWeb(context);
    } else {
      _printAndroid(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        title: const Text('Order Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartController.cartLines.length,
                itemBuilder: (context, index) {
                  final line = cartController.cartLines[index];
                  return Obx(() {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              line.item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            'x${line.qty.value}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '₹${line.lineTotal.toStringAsFixed(0)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Obx(() {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '₹${cartController.total.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onPrint(context),
                      child: const Text(
                        'Print',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
