import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import 'history_provider.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  bool _voiding = false;

  Future<void> _handleVoid() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Void Transaksi?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Stok akan dikembalikan dan transaksi ditandai batal. Tindakan ini tidak bisa dibatalkan.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Alasan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Void', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _voiding = true);

    try {
      final service = ref.read(historyServiceProvider);
      await service.voidTransaction(widget.transactionId, reasonController.text.trim());

      ref.invalidate(transactionDetailProvider(widget.transactionId));
      ref.invalidate(transactionHistoryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil di-void')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal void transaksi'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _voiding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(transactionDetailProvider(widget.transactionId));
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: detailAsync.when(
        data: (trx) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(trx.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  if (trx.isVoided)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Voided', style: TextStyle(fontSize: 11, color: AppColors.danger)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(trx.createdAt.toLocal()),
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (trx.cashierName != null)
                Text('Kasir: ${trx.cashierName}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...trx.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.qty} x ${Formatter.rupiah(item.price)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                Text(Formatter.rupiah(item.subtotal), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            if (item.note != null && item.note!.isNotEmpty)
                              Text(
                                'Catatan: ${item.note}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.border),
                    _row('Subtotal', Formatter.rupiah(trx.subtotal)),
                    if (trx.discount > 0) _row('Diskon', '-${Formatter.rupiah(trx.discount)}'),
                    const SizedBox(height: 6),
                    _row('Total', Formatter.rupiah(trx.total), bold: true),
                    if (trx.paymentMethod != null) ...[
                      const SizedBox(height: 6),
                      _row('Metode', trx.paymentMethod!.toUpperCase()),
                    ],
                    if (trx.amountReceived != null) _row('Diterima', Formatter.rupiah(trx.amountReceived!)),
                    if (trx.changeAmount != null) _row('Kembalian', Formatter.rupiah(trx.changeAmount!)),
                  ],
                ),
              ),

              if (trx.isVoided) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Di-void oleh: ${trx.voidedByName ?? "-"}', style: const TextStyle(fontSize: 12)),
                      if (trx.voidedAt != null)
                        Text(
                          dateFormat.format(trx.voidedAt!.toLocal()),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      if (trx.voidReason != null && trx.voidReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Alasan: ${trx.voidReason}', style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ],

              if (!trx.isVoided) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _voiding ? null : _handleVoid,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: _voiding
                        ? const SizedBox(
                            height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.undo, size: 16),
                    label: Text(_voiding ? 'Memproses...' : 'Void Transaksi Ini'),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Gagal memuat detail: $error', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}