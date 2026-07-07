import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import 'cart_item.dart';

class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
}

class TransactionItemResult {
  final String productName;
  final double price;
  final int qty;
  final double subtotal;
  final String? note;

  TransactionItemResult({
    required this.productName,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.note,
  });

  factory TransactionItemResult.fromJson(Map<String, dynamic> json) {
    return TransactionItemResult(
      productName: json['product_name'],
      price: double.parse(json['price'].toString()),
      qty: json['qty'],
      subtotal: double.parse(json['subtotal'].toString()),
      note: json['note'],
    );
  }
}

class TransactionResult {
  final int id;
  final String invoiceNumber;
  final double total;
  final double? amountReceived;
  final double? changeAmount;
  final List<TransactionItemResult> items;

  TransactionResult({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    this.amountReceived,
    this.changeAmount,
    this.items = const [],
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'];
    final List itemsJson = json['items'] ?? [];

    return TransactionResult(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      total: double.parse(json['total'].toString()),
      amountReceived: payment?['amount_received'] != null
          ? double.parse(payment['amount_received'].toString())
          : null,
      changeAmount: payment?['change_amount'] != null
          ? double.parse(payment['change_amount'].toString())
          : null,
      items: itemsJson.map((item) => TransactionItemResult.fromJson(item)).toList(),
    );
  }
}

class TransactionService {
  Future<TransactionResult> create({
    required List<CartItem> items,
    required double transactionDiscount,
    required String paymentMethod,
    double? amountReceived,
    String? customerPhone,
  }) async {
    final dio = await DioClient.getInstance();

    try {
      final response = await dio.post('/transactions', data: {
        'items': items
            .map((item) => {
                  'product_id': item.product.id,
                  'qty': item.qty,
                  'discount': item.discount,
                  if (item.note != null && item.note!.isNotEmpty) 'note': item.note,
                })
            .toList(),
        'discount': transactionDiscount,
        'payment': {
          'method': paymentMethod,
          if (amountReceived != null) 'amount_received': amountReceived,
        },
        if (customerPhone != null && customerPhone.isNotEmpty) 'customer_phone': customerPhone,
      });

      return TransactionResult.fromJson(response.data['data']);
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      final message = (firstError is List ? firstError.first : null) ??
          e.response?.data?['message'] ??
          'Transaksi gagal, periksa koneksi Anda';
      throw TransactionException(message.toString());
    }
  }
}