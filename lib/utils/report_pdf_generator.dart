import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/pos_order.dart';
import '../models/report_data.dart';

class ReportPdfGenerator {
  static Future<void> generateAndDownload({
    required String shopName,
    required DateTime startDate,
    required DateTime endDate,
    required ReportSummary summary,
    required List<PosOrder> orders,
    required PaymentBreakdown paymentBreakdown,
    required List<TopItemData> topItems,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(shopName, startDate, endDate),
          pw.SizedBox(height: 24),
          _buildSummarySection(summary),
          pw.SizedBox(height: 24),
          _buildPaymentBreakdown(paymentBreakdown),
          pw.SizedBox(height: 24),
          _buildTopItems(topItems),
          pw.SizedBox(height: 24),
          _buildOrdersTable(orders),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildHeader(String shopName, DateTime start, DateTime end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          shopName,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Sales Report',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSummarySection(ReportSummary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryCard('Total Sales', '₹${summary.totalSales.toStringAsFixed(2)}'),
            _buildSummaryCard('Total Orders', summary.totalOrders.toString()),
            _buildSummaryCard('Avg Order', '₹${summary.avgOrderValue.toStringAsFixed(2)}'),
            _buildSummaryCard('Customers', summary.totalCustomers.toString()),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentBreakdown(PaymentBreakdown breakdown) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Payment Breakdown',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildPaymentCard(
                'Cash',
                breakdown.cashAmount,
                breakdown.cashPercentage,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _buildPaymentCard(
                'Online',
                breakdown.onlineAmount,
                breakdown.onlinePercentage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentCard(String label, double amount, double percentage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTopItems(List<TopItemData> items) {
    if (items.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top Items',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Item', isHeader: true),
                _buildTableCell('Quantity', isHeader: true),
                _buildTableCell('Revenue', isHeader: true),
              ],
            ),
            ...items.map((item) => pw.TableRow(
                  children: [
                    _buildTableCell(item.itemName),
                    _buildTableCell(item.quantity.toString()),
                    _buildTableCell('₹${item.revenue.toStringAsFixed(2)}'),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildOrdersTable(List<PosOrder> orders) {
    if (orders.isEmpty) return pw.SizedBox();

    final displayOrders = orders.take(20).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Orders',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Order ID', isHeader: true),
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
                _buildTableCell('Payment', isHeader: true),
              ],
            ),
            ...displayOrders.map((order) => pw.TableRow(
                  children: [
                    _buildTableCell(order.id.substring(0, 8)),
                    _buildTableCell(DateFormat('dd/MM HH:mm').format(order.createdAt)),
                    _buildTableCell('₹${order.total.toStringAsFixed(2)}'),
                    _buildTableCell(order.paymentMode.name.toUpperCase()),
                  ],
                )),
          ],
        ),
        if (orders.length > 20)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Showing 20 of ${orders.length} orders',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
