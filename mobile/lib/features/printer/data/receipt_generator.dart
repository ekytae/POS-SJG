import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../../../core/utils/formatter.dart';
import '../../transaction/data/transaction_service.dart';

class ReceiptGenerator {
  static Future<List<int>> generate({
    required TransactionResult transaction,
    required String storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      storeName,
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );

    if (storeAddress != null && storeAddress.isNotEmpty) {
      bytes += generator.text(storeAddress, styles: const PosStyles(align: PosAlign.center));
    }
    if (storePhone != null && storePhone.isNotEmpty) {
      bytes += generator.text(storePhone, styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.hr();
    bytes += generator.text(transaction.invoiceNumber, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    for (final item in transaction.items) {
      bytes += generator.text(item.productName);
      bytes += generator.row([
        PosColumn(text: '${item.qty} x ${Formatter.rupiah(item.price)}', width: 8),
        PosColumn(
          text: Formatter.rupiah(item.subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      if (item.note != null && item.note!.isNotEmpty) {
        bytes += generator.text('  Catatan: ${item.note}', styles: const PosStyles(align: PosAlign.left));
      }
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Total', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: Formatter.rupiah(transaction.total),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    if (transaction.amountReceived != null) {
      bytes += generator.row([
        PosColumn(text: 'Bayar', width: 6),
        PosColumn(
          text: Formatter.rupiah(transaction.amountReceived!),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (transaction.changeAmount != null) {
      bytes += generator.row([
        PosColumn(text: 'Kembali', width: 6),
        PosColumn(
          text: Formatter.rupiah(transaction.changeAmount!),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.text(
      'Terima kasih!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}