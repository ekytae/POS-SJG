import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import 'cart_provider.dart';
import 'payment_provider.dart';

const _paymentMethods = [
  {'value': 'cash', 'label': 'Tunai', 'icon': Icons.payments_outlined},
  {'value': 'qris', 'label': 'QRIS', 'icon': Icons.qr_code},
  {'value': 'transfer', 'label': 'Transfer', 'icon': Icons.account_balance_outlined},
  {'value': 'ewallet', 'label': 'E-Wallet', 'icon': Icons.wallet_outlined},
];

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'cash';
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _amountReceived => double.tryParse(_amountController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final paymentState = ref.watch(paymentProvider);

    ref.listen(paymentProvider, (previous, next) {
      if (next.result != null) {
        context.pushReplacement('/transaction-success', extra: next.result);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
    });

    final change = _selectedMethod == 'cash' ? _amountReceived - cart.total : 0;
    final canSubmit = _selectedMethod != 'cash' || _amountReceived >= cart.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: AppColors.textMuted)),
                    Text(Formatter.rupiah(cart.subtotal)),
                  ],
                ),
                if (cart.transactionDiscount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diskon', style: TextStyle(color: AppColors.textMuted)),
                      Text(
                        '-${Formatter.rupiah(cart.transactionDiscount)}',
                        style: const TextStyle(color: AppColors.positive),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 20, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      Formatter.rupiah(cart.total),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _paymentMethods.map((method) {
              final isSelected = _selectedMethod == method['value'];
              return InkWell(
                onTap: () => setState(() => _selectedMethod = method['value'] as String),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSoft : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        size: 18,
                        color: isSelected ? AppColors.accent : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        method['label'] as String,
                        style: TextStyle(
                          color: isSelected ? AppColors.accent : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedMethod == 'cash') ...[
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Uang Diterima (Rp)'),
            ),
            if (_amountController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: change >= 0 ? AppColors.positive.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      change >= 0 ? 'Kembalian' : 'Kurang',
                      style: TextStyle(color: change >= 0 ? AppColors.positive : AppColors.danger),
                    ),
                    Text(
                      Formatter.rupiah(change.abs()),
                      style: TextStyle(
                        color: change >= 0 ? AppColors.positive : AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'No. WhatsApp Pelanggan (opsional)',
              hintText: 'Untuk kirim struk digital',
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (!canSubmit || paymentState.isSubmitting) ? null : _handleSubmit,
            child: paymentState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Konfirmasi Pembayaran'),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    ref.read(paymentProvider.notifier).submit(
          paymentMethod: _selectedMethod,
          amountReceived: _selectedMethod == 'cash' ? _amountReceived : null,
          customerPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );
  }
}