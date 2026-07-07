import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int qty;
  final double discount;
  final String? note;

  CartItem({
    required this.product,
    this.qty = 1,
    this.discount = 0,
    this.note,
  });

  double get subtotal => (product.price * qty) - discount;

  CartItem copyWith({int? qty, double? discount, String? note, bool clearNote = false}) {
    return CartItem(
      product: product,
      qty: qty ?? this.qty,
      discount: discount ?? this.discount,
      note: clearNote ? null : (note ?? this.note),
    );
  }
}