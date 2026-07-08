import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import '../../printer/data/receipt_generator.dart';
import '../../printer/presentation/printer_provider.dart';
import '../../printer/presentation/widgets/whatsapp_receipt_sheet.dart';
import '../data/transaction_service.dart';

class TransactionSuccessScreen extends ConsumerWidget {
  final TransactionResult result;

  const TransactionSuccessScreen({super.key, required this.result});

  Future<void> _handlePrint(BuildContext context, WidgetRef ref) async {
    final printers = await ref.read(printersProvider.future);
    final defaultPrinter = printers.where((p) => p.isDefault).firstOrNull;

    if (defaultPrinter == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada printer default, atur dulu di Konfigurasi Printer')),
        );
      }
      return;
    }

    final bluetoothService = ref.read(bluetoothPrinterServiceProvider);
    final storeSettings = await ref.read(storeSettingsProvider.future);

    try {
      final connected = await bluetoothService.connect(defaultPrinter.macAddress);
      if (!connected) throw Exception('Gagal terhubung ke printer');

      final bytes = await ReceiptGenerator.generate(
        transaction: result,
        storeName: storeSettings.storeName,
        storeAddress: storeSettings.storeAddress,
        storePhone: storeSettings.storePhone,
      );

      await bluetoothService.printBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Struk berhasil dicetak')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencetak struk'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefetch storeSettings begitu halaman ini dibuka, supaya saat tombol
    // WhatsApp ditekan nanti, datanya sudah siap tanpa perlu await lagi.
    final storeSettingsAsync = ref.watch(storeSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.positive.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.positive, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Transaksi Berhasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(result.invoiceNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _row('Total', Formatter.rupiah(result.total)),
                    if (result.amountReceived != null) ...[
                      const SizedBox(height: 10),
                      _row('Diterima', Formatter.rupiah(result.amountReceived!)),
                    ],
                    if (result.changeAmount != null) ...[
                      const SizedBox(height: 10),
                      _row('Kembalian', Formatter.rupiah(result.changeAmount!), accent: true),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handlePrint(context, ref),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Cetak Struk'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showWhatsAppReceiptSheet(
                    context,
                    result,
                    storeSettingsAsync.value, // null kalau masih loading, sheet akan pakai fallback nama
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Kirim Struk via WhatsApp'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Transaksi Baru'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool accent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: accent ? AppColors.accent : AppColors.textPrimary),
        ),
      ],
    );
  }
}