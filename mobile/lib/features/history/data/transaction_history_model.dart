class TransactionListItem {
  final int id;
  final String invoiceNumber;
  final double total;
  final String status;
  final DateTime createdAt;
  final String? cashierName;

  TransactionListItem({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.status,
    required this.createdAt,
    this.cashierName,
  });

  factory TransactionListItem.fromJson(Map<String, dynamic> json) {
    return TransactionListItem(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      total: double.parse(json['total'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      cashierName: json['cashier']?['name'],
    );
  }

  bool get isVoided => status == 'voided';
}

class TransactionDetailItem {
  final String productName;
  final double price;
  final int qty;
  final double discount;
  final double subtotal;
  final String? note;

  TransactionDetailItem({
    required this.productName,
    required this.price,
    required this.qty,
    required this.discount,
    required this.subtotal,
    this.note,
  });

  factory TransactionDetailItem.fromJson(Map<String, dynamic> json) {
    return TransactionDetailItem(
      productName: json['product_name'],
      price: double.parse(json['price'].toString()),
      qty: json['qty'],
      discount: double.parse((json['discount'] ?? 0).toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      note: json['note'],
    );
  }
}

class TransactionDetailModel {
  final int id;
  final String invoiceNumber;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final DateTime createdAt;
  final String? cashierName;
  final String? paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? voidedByName;
  final DateTime? voidedAt;
  final String? voidReason;
  final List<TransactionDetailItem> items;

  TransactionDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.createdAt,
    this.cashierName,
    this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.voidedByName,
    this.voidedAt,
    this.voidReason,
    this.items = const [],
  });

  bool get isVoided => status == 'voided';

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'];
    final List itemsJson = json['items'] ?? [];

    return TransactionDetailModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      subtotal: double.parse(json['subtotal'].toString()),
      discount: double.parse(json['discount'].toString()),
      total: double.parse(json['total'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      cashierName: json['cashier']?['name'],
      paymentMethod: payment?['method'],
      amountReceived: payment?['amount_received'] != null
          ? double.parse(payment['amount_received'].toString())
          : null,
      changeAmount: payment?['change_amount'] != null
          ? double.parse(payment['change_amount'].toString())
          : null,
      voidedByName: json['voided_by_user']?['name'],
      voidedAt: json['voided_at'] != null ? DateTime.parse(json['voided_at']) : null,
      voidReason: json['void_reason'],
      items: itemsJson.map((item) => TransactionDetailItem.fromJson(item)).toList(),
    );
  }
}