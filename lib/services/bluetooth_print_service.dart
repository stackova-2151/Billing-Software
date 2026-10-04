import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pos_order.dart';

class BluetoothPrintService {
  static const _prefKey = 'bt_printer_mac';

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<List<BluetoothInfo>> getPairedDevices() async {
    final allDevices = await PrintBluetoothThermal.pairedBluetooths;
    // Filter to show only thermal/POS printers
    return allDevices.where(_isLikelyPrinter).toList();
  }

  /// Conservative filter to identify thermal printers based on device name.
  /// The print_bluetooth_thermal library doesn't expose device type/capability metadata,
  /// so we use name-based filtering as a fallback.
  bool _isLikelyPrinter(BluetoothInfo device) {
    final name = device.name.toLowerCase().trim();

    // Explicitly reject obvious non-printer devices
    final nonPrinterKeywords = [
      'airpod',
      'earbud',
      'buds',
      'headphone',
      'headset',
      'speaker',
      'jbl',
      'bose',
      'sony',
      'watch',
      'smartwatch',
      'keyboard',
      'mouse',
      'iphone',
      'phone',
      'galaxy',
      'laptop',
      'computer',
      'pc',
      'car',
      'vehicle',
      'audio',
      'band',
      'tablet',
      'ipad',
    ];

    if (nonPrinterKeywords.any((keyword) => name.contains(keyword))) {
      return false;
    }

    // Accept common printer keywords/brands/models
    final printerKeywords = [
      'printer',
      'thermal',
      'receipt',
      'pos',
      'xprinter',
      'rongta',
      'goojprt',
      'munbyn',
      'hprt',
      'hoin',
      'zjiang',
      'zj-',
      'zj ',
      'xp-',
      'xp ',
      'pos58',
      'pos80',
      'pos-58',
      'pos-80',
      'mt-p',
      'mtp',
      'mtp-ii',
      'epson',
      'bixolon',
      'sewoo',
      'snbc',
      'star',
      'micronics',
      'zkteco',
      '58mm',
      '80mm',
      'esc',
      'rpt',
      'pt-',
      'gprinter',
      'crown',
      'bt printer',
      'bluetooth printer',
    ];

    return printerKeywords.any((keyword) => name.contains(keyword));
  }

  Future<void> savePrinterMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mac);
  }

  Future<String?> getSavedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> clearSavedMac() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<bool> connect(String mac) async {
    final connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) return true;
    return await PrintBluetoothThermal.connect(macPrinterAddress: mac);
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<bool> printBill(PosOrder order, String shopName) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final List<int> bytes = [];

    bytes.addAll(
      generator.text(
        shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'Bill Receipt',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());

    for (final line in order.lines) {
      bytes.addAll(
        generator.row([
          PosColumn(text: line.itemName, width: 7),
          PosColumn(
            text: 'x${line.qty}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: line.lineTotal.toStringAsFixed(0),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.row([
        PosColumn(text: 'Subtotal', width: 8),
        PosColumn(
          text: order.subtotal.toStringAsFixed(0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    bytes.addAll(
      generator.row([
        PosColumn(text: 'GST (5%)', width: 8),
        PosColumn(
          text: order.gstAmount.toStringAsFixed(0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    bytes.addAll(generator.hr(ch: '='));
    bytes.addAll(
      generator.row([
        PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(
          text: order.total.toStringAsFixed(0),
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]),
    );
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        'Payment: ${order.paymentMode.name.toUpperCase()}',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(
      generator.text(
        'Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return await PrintBluetoothThermal.writeBytes(bytes);
  }
}
