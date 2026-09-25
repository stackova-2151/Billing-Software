import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../services/bluetooth_print_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  static const _accent = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F7FF);
  static const _border = Color(0xFFEAE8FF);

  final _service = BluetoothPrintService();

  List<BluetoothInfo> _devices = [];
  String? _savedMac;
  bool _isConnected = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final mac = await _service.getSavedMac();
    final connected = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      _savedMac = mac;
      _isConnected = connected;
      _loading = false;
    });
  }

  Future<void> _loadDevices() async {
    final granted = await _service.requestPermissions();
    if (!granted) {
      _snack('Bluetooth permissions required.');
      return;
    }
    setState(() => _loading = true);
    final devices = await _service.getPairedDevices();
    setState(() {
      _devices = devices;
      _loading = false;
    });
    if (devices.isEmpty) {
      _snack('No paired devices found. Pair your printer in Settings → Bluetooth first.');
    }
  }

  Future<void> _connect(BluetoothInfo device) async {
    setState(() => _loading = true);
    await _service.savePrinterMac(device.macAdress);
    final ok = await _service.connect(device.macAdress);
    final connected = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      _savedMac = device.macAdress;
      _isConnected = connected;
      _loading = false;
    });
    _snack(ok ? 'Connected to ${device.name}' : 'Failed to connect. Make sure printer is on.');
  }

  Future<void> _disconnect() async {
    setState(() => _loading = true);
    await _service.disconnect();
    setState(() {
      _isConnected = false;
      _loading = false;
    });
    _snack('Disconnected.');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildStatusCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  const Text(
                    'Paired Devices',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B3A),
                    ),
                  ),
                  const Spacer(),
                  _OutlineBtn(
                    icon: Icons.refresh_rounded,
                    label: 'Scan',
                    onTap: _loadDevices,
                  ),
                ],
              ),
            ),
            Expanded(child: _buildDeviceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.print_rounded, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Printer Setup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1B3A),
                ),
              ),
              Text(
                'Bluetooth thermal printer',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B6880)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isConnected
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isConnected
                  ? Icons.bluetooth_connected_rounded
                  : Icons.bluetooth_disabled_rounded,
              color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'Connected' : 'Not Connected',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _isConnected
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1E1B3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _savedMac ?? 'No printer selected',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B6880),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            )
          else if (_isConnected)
            GestureDetector(
              onTap: _disconnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Disconnect',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _accent),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth_searching_rounded,
                  color: _accent, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'No devices listed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B3A),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tap Scan to load paired devices, or pair your printer in Settings → Bluetooth first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B6880)),
              ),
            ),
            const SizedBox(height: 20),
            _OutlineBtn(
              icon: Icons.bluetooth_searching_rounded,
              label: 'Scan for Devices',
              onTap: _loadDevices,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final device = _devices[i];
        final isSaved = device.macAdress == _savedMac;
        return _DeviceTile(
          device: device,
          isSaved: isSaved,
          isConnected: isSaved && _isConnected,
          onConnect: () => _connect(device),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);
  final BluetoothInfo device;
  final bool isSaved;
  final bool isConnected;
  final VoidCallback onConnect;

  const _DeviceTile({
    required this.device,
    required this.isSaved,
    required this.isConnected,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF22C55E).withOpacity(0.5)
              : isSaved
                  ? _accent.withOpacity(0.4)
                  : const Color(0xFFEAE8FF),
          width: isConnected || isSaved ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isConnected
                ? const Color(0xFF22C55E).withOpacity(0.1)
                : _accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isConnected
                ? Icons.print_rounded
                : Icons.bluetooth_rounded,
            color: isConnected ? const Color(0xFF22C55E) : _accent,
            size: 20,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1B3A),
          ),
        ),
        subtitle: Text(
          device.macAdress,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B6880),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isConnected
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              )
            : GestureDetector(
                onTap: onConnect,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: _accent.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
          color: _accent.withOpacity(0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: _accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
