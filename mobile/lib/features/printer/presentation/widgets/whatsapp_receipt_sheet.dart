import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/whatsapp_receipt_service.dart';
import '../../data/receipt_image_service.dart';
import '../../data/store_settings_service.dart';
import '../../../transaction/data/transaction_service.dart';

Future<void> showWhatsAppReceiptSheet(
  BuildContext context,
  TransactionResult transaction,
  StoreSettings? storeSettings,
) async {
  final phoneController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: AppColors.positive, size: 20),
                const SizedBox(width: 8),
                const Text('Kirim Struk Digital', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Kirim Teks (nomor otomatis terisi)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp Pelanggan',
                hintText: '08123456789',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (phoneController.text.trim().isEmpty) return;

                  final message = WhatsAppReceiptService.buildReceiptText(
                    transaction: transaction,
                    storeName: storeSettings?.storeName ?? 'Toko Saya',
                    storeAddress: storeSettings?.storeAddress,
                    storePhone: storeSettings?.storePhone,
                  );

                  WhatsAppReceiptService.sendViaWhatsApp(
                    phoneNumber: phoneController.text.trim(),
                    message: message,
                  );

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Kirim sebagai Teks'),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            const Text(
              'Atau kirim sebagai gambar (pilih kontak manual)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await ReceiptImageService.shareAsImage(
                    transaction: transaction,
                    storeSettings: storeSettings,
                  );
                },
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Kirim sebagai Gambar'),
              ),
            ),
          ],
        ),
      );
    },
  );
}