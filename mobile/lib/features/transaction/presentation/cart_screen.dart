import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: cart.isEmpty
          ? const Center(
              child: Text('Keranjang masih kosong', style: TextStyle(color: AppColors.textMuted)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => cartNotifier.removeItem(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatter.rupiah(item.product.price),
                          style: const TextStyle(color: AppColors.accent, fontSize: 13),
                        ),
                        if (item.note != null && item.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Catatan: ${item.note}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                        if (item.discount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Diskon: ${Formatter.rupiah(item.discount)}',
                            style: const TextStyle(color: AppColors.positive, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showItemOptionsSheet(context, ref, index, item),
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                              label: const Text(
                                'Catatan / Diskon',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            ),
                            Row(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: () => cartNotifier.decrementQty(index),
                                ),
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.qty}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: item.qty >= item.product.stock
                                      ? null
                                      : () => cartNotifier.incrementQty(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                _TransactionDiscountTile(),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: AppColors.textMuted)),
                        Text(
                          Formatter.rupiah(cart.total),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/payment'),
                        child: const Text('Lanjut ke Pembayaran'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showItemOptionsSheet(BuildContext context, WidgetRef ref, int index, item) {
    final noteController = TextEditingController(text: item.note ?? '');
    final discountController = TextEditingController(
      text: item.discount > 0 ? item.discount.toStringAsFixed(0) : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
              Text('${item.product.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Catatan (misal: less ice)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diskon (Rp)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateItemNote(index, noteController.text);
                    ref.read(cartProvider.notifier).updateItemDiscount(
                          index,
                          double.tryParse(discountController.text) ?? 0,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.base : AppColors.accentSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.textMuted : AppColors.accent),
      ),
    );
  }
}

class _TransactionDiscountTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TransactionDiscountTile> createState() => _TransactionDiscountTileState();
}

class _TransactionDiscountTileState extends ConsumerState<_TransactionDiscountTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = ref.read(cartProvider).transactionDiscount;
    _controller = TextEditingController(text: current > 0 ? current.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Diskon Total Transaksi (Rp, opsional)'),
      onChanged: (value) {
        ref.read(cartProvider.notifier).setTransactionDiscount(double.tryParse(value) ?? 0);
      },
    );
  }
}