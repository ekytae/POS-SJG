import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../data/bluetooth_printer_service.dart';
import 'printer_provider.dart';

class PrinterConfigScreen extends ConsumerStatefulWidget {
  const PrinterConfigScreen({super.key});

  @override
  ConsumerState<PrinterConfigScreen> createState() => _PrinterConfigScreenState();
}

class _PrinterConfigScreenState extends ConsumerState<PrinterConfigScreen> {
  List<BluetoothDeviceInfo> _pairedDevices = [];
  bool _scanning = false;
  String? _testingMac;

  Future<void> _scanDevices() async {
    setState(() => _scanning = true);

    final bluetoothService = ref.read(bluetoothPrinterServiceProvider);
    final granted = await bluetoothService.requestPermissions();

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin Bluetooth diperlukan untuk mencari printer')),
        );
      }
      setState(() => _scanning = false);
      return;
    }

    final devices = await bluetoothService.getPairedDevices();
    setState(() {
      _pairedDevices = devices;
      _scanning = false;
    });
  }

  Future<void> _saveAsDefaultPrinter(BluetoothDeviceInfo device) async {
    final printerService = ref.read(printerServiceProvider);

    try {
      final printer = await printerService.addPrinter(device.name, device.macAddress);
      await printerService.setDefault(printer.id);
      ref.invalidate(printersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${device.name} berhasil disimpan sebagai printer default')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan printer'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _testPrint(BluetoothDeviceInfo device) async {
    setState(() => _testingMac = device.macAddress);

    final bluetoothService = ref.read(bluetoothPrinterServiceProvider);

    try {
      final connected = await bluetoothService.connect(device.macAddress);
      if (!connected) throw Exception('Gagal terhubung');

      // Test print sederhana tanpa perlu esc_pos_utils, cukup teks biasa
      await bluetoothService.printBytes([0x1B, 0x40]); // ESC @ (reset)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil terhubung ke ${device.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test print gagal'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      setState(() => _testingMac = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedPrintersAsync = ref.watch(printersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Printer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Printer Tersimpan', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          savedPrintersAsync.when(
            data: (printers) {
              if (printers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Belum ada printer tersimpan', style: TextStyle(color: AppColors.textMuted)),
                );
              }
              return Column(
                children: printers
                    .map(
                      (p) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.isDefault ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.print_outlined, size: 20, color: AppColors.textMuted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    p.macAddress,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (p.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(fontSize: 10, color: AppColors.accent),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Gagal memuat printer', style: TextStyle(color: AppColors.danger)),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Printer Bluetooth Terpasang', style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _scanning ? null : _scanDevices,
                icon: _scanning
                    ? const SizedBox(
                        height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('Scan'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan printer sudah di-pair lewat Pengaturan Bluetooth HP terlebih dahulu.',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          if (_pairedDevices.isEmpty && !_scanning)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Tekan "Scan" untuk mencari printer', style: TextStyle(color: AppColors.textMuted)),
            ),

          ..._pairedDevices.map(
            (device) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(device.macAddress, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _testingMac == device.macAddress ? null : () => _testPrint(device),
                          child: _testingMac == device.macAddress
                              ? const SizedBox(
                                  height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Test Koneksi', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveAsDefaultPrinter(device),
                          child: const Text('Simpan sebagai Default', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}