import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/formatter.dart';
import '../../transaction/data/transaction_service.dart';

class WhatsAppReceiptService {
  static String normalizePhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    } else if (!digits.startsWith('62')) {
      digits = '62$digits';
    }

    return digits;
  }

  static String buildReceiptText({
    required TransactionResult transaction,
    required String storeName,
    String? storeAddress,
    String? storePhone,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('*$storeName*');
    if (storeAddress != null && storeAddress.isNotEmpty) buffer.writeln(storeAddress);
    if (storePhone != null && storePhone.isNotEmpty) buffer.writeln(storePhone);
    buffer.writeln('');
    buffer.writeln('Struk: ${transaction.invoiceNumber}');
    buffer.writeln('------------------------------');

    for (final item in transaction.items) {
      buffer.writeln(item.productName);
      buffer.writeln('  ${item.qty} x ${Formatter.rupiah(item.price)} = ${Formatter.rupiah(item.subtotal)}');
      if (item.note != null && item.note!.isNotEmpty) {
        buffer.writeln('  Catatan: ${item.note}');
      }
    }

    buffer.writeln('------------------------------');
    buffer.writeln('*Total: ${Formatter.rupiah(transaction.total)}*');

    if (transaction.amountReceived != null) {
      buffer.writeln('Bayar: ${Formatter.rupiah(transaction.amountReceived!)}');
    }
    if (transaction.changeAmount != null) {
      buffer.writeln('Kembali: ${Formatter.rupiah(transaction.changeAmount!)}');
    }

    buffer.writeln('');
    buffer.writeln('Terima kasih telah berbelanja! 🙏');

    return buffer.toString();
  }

  static Future<bool> sendViaWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$normalizedPhone?text=$encodedMessage');

    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}