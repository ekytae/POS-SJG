import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../data/store_settings_service.dart';
import '../../../transaction/data/transaction_service.dart';

class ReceiptImageWidget extends StatelessWidget {
  final TransactionResult transaction;
  final StoreSettings? storeSettings;

  const ReceiptImageWidget({super.key, required this.transaction, this.storeSettings});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              storeSettings?.storeName ?? 'Toko Saya',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            if (storeSettings?.storeAddress != null && storeSettings!.storeAddress!.isNotEmpty)
              Text(
                storeSettings!.storeAddress!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            if (storeSettings?.storePhone != null && storeSettings!.storePhone!.isNotEmpty)
              Text(
                storeSettings!.storePhone!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            const SizedBox(height: 12),
            const _DashedLine(),
            const SizedBox(height: 8),
            Text(
              transaction.invoiceNumber,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const _DashedLine(),
            const SizedBox(height: 8),

            ...transaction.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.qty} x ${Formatter.rupiah(item.price)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          Formatter.rupiah(item.subtotal),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    if (item.note != null && item.note!.isNotEmpty)
                      Text(
                        'Catatan: ${item.note}',
                        style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),

            const _DashedLine(),
            const SizedBox(height: 8),
            _totalRow('Total', transaction.total, bold: true),
            if (transaction.amountReceived != null)
              _totalRow('Bayar', transaction.amountReceived!),
            if (transaction.changeAmount != null)
              _totalRow('Kembali', transaction.changeAmount!),

            const SizedBox(height: 16),
            const Text(
              'Terima kasih telah berbelanja!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            Formatter.rupiah(value),
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.black26);
  }
}