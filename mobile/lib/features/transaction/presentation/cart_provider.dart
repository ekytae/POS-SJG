import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cart_item.dart';
import '../data/product_model.dart';

class CartState {
  final List<CartItem> items;
  final double transactionDiscount;
  final String? customerPhone;

  CartState({
    this.items = const [],
    this.transactionDiscount = 0,
    this.customerPhone,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - transactionDiscount;
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    double? transactionDiscount,
    String? customerPhone,
  }) {
    return CartState(
      items: items ?? this.items,
      transactionDiscount: transactionDiscount ?? this.transactionDiscount,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      incrementQty(existingIndex);
      return;
    }

    state = state.copyWith(items: [...state.items, CartItem(product: product)]);
  }

  void incrementQty(int index) {
    final item = state.items[index];

    if (item.qty >= item.product.stock) return; // Tidak boleh melebihi stok

    final updated = [...state.items];
    updated[index] = item.copyWith(qty: item.qty + 1);
    state = state.copyWith(items: updated);
  }

  void decrementQty(int index) {
    final item = state.items[index];

    if (item.qty <= 1) {
      removeItem(index);
      return;
    }

    final updated = [...state.items];
    updated[index] = item.copyWith(qty: item.qty - 1);
    state = state.copyWith(items: updated);
  }

  void removeItem(int index) {
    final updated = [...state.items]..removeAt(index);
    state = state.copyWith(items: updated);
  }

  void updateItemDiscount(int index, double discount) {
    final updated = [...state.items];
    updated[index] = updated[index].copyWith(discount: discount);
    state = state.copyWith(items: updated);
  }

  void updateItemNote(int index, String? note) {
    final updated = [...state.items];
    updated[index] = updated[index].copyWith(note: note, clearNote: note == null || note.isEmpty);
    state = state.copyWith(items: updated);
  }

  void setTransactionDiscount(double discount) {
    state = state.copyWith(transactionDiscount: discount);
  }

  void setCustomerPhone(String? phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);