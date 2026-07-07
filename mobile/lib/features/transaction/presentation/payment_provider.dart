import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_service.dart';
import 'cart_provider.dart';
import 'product_provider.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

class PaymentState {
  final bool isSubmitting;
  final String? error;
  final TransactionResult? result;

  PaymentState({this.isSubmitting = false, this.error, this.result});
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => PaymentState();

  Future<void> submit({
    required String paymentMethod,
    double? amountReceived,
    String? customerPhone,
  }) async {
    state = PaymentState(isSubmitting: true);

    final cart = ref.read(cartProvider);
    final service = ref.read(transactionServiceProvider);

    try {
      final result = await service.create(
        items: cart.items,
        transactionDiscount: cart.transactionDiscount,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        customerPhone: customerPhone,
      );

      state = PaymentState(result: result);

      // Sukses: kosongkan keranjang & refresh daftar produk (stok berubah)
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(productsProvider);
    } on TransactionException catch (e) {
      state = PaymentState(error: e.message);
    }
  }

  void reset() {
    state = PaymentState();
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);