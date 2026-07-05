<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\StockMovementType;
use App\Enums\TransactionStatus;
use App\Models\Payment;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class TransactionService
{
    /**
     * Buat transaksi baru: validasi stok, hitung total, simpan detail,
     * kurangi stok, catat stock movement, dan simpan pembayaran.
     * Semua dalam satu DB transaction (atomic).
     */
    public function create(array $data, int $userId): Transaction
    {
        return DB::transaction(function () use ($data, $userId) {
            $subtotal = 0;
            $preparedItems = [];

            // 1. Validasi stok & siapkan snapshot data tiap item
            foreach ($data['items'] as $item) {
                $product = Product::lockForUpdate()->find($item['product_id']);

                if (!$product || !$product->is_active) {
                    throw ValidationException::withMessages([
                        "items" => ["Produk ID {$item['product_id']} tidak tersedia"],
                    ]);
                }

                if ($product->stock < $item['qty']) {
                    throw ValidationException::withMessages([
                        "items" => ["Stok {$product->name} tersisa {$product->stock}, diminta {$item['qty']}"],
                    ]);
                }

                $itemDiscount = $item['discount'] ?? 0;
                $itemSubtotal = ($product->price * $item['qty']) - $itemDiscount;

                $preparedItems[] = [
                    'product'   => $product,
                    'qty'       => $item['qty'],
                    'discount'  => $itemDiscount,
                    'note'      => $item['note'] ?? null,
                    'subtotal'  => $itemSubtotal,
                ];

                $subtotal += $itemSubtotal;
            }

            $transactionDiscount = $data['discount'] ?? 0;
            $total = $subtotal - $transactionDiscount;

            // 2. Hitung pembayaran (server yang hitung, bukan percaya client)
            $paymentMethod = PaymentMethod::from($data['payment']['method']);
            $amountReceived = null;
            $changeAmount = null;

            if ($paymentMethod === PaymentMethod::Cash) {
                $amountReceived = $data['payment']['amount_received'];

                if ($amountReceived < $total) {
                    throw ValidationException::withMessages([
                        'payment.amount_received' => ['Uang diterima kurang dari total belanja'],
                    ]);
                }

                $changeAmount = $amountReceived - $total;
            }

            // 3. Simpan transaksi (invoice_number diisi setelah tahu ID)
            $transaction = Transaction::create([
                'invoice_number' => 'TEMP',
                'user_id'        => $userId,
                'subtotal'       => $subtotal,
                'discount'       => $transactionDiscount,
                'total'          => $total,
                'status'         => TransactionStatus::Completed,
                'customer_phone' => $data['customer_phone'] ?? null,
            ]);

            $transaction->update([
                'invoice_number' => 'INV-' . str_pad($transaction->id, 6, '0', STR_PAD_LEFT),
            ]);

            // 4. Simpan detail transaksi + kurangi stok + catat stock movement
            foreach ($preparedItems as $prepared) {
                $product = $prepared['product'];

                TransactionDetail::create([
                    'transaction_id' => $transaction->id,
                    'product_id'     => $product->id,
                    'product_name'   => $product->name, // snapshot
                    'price'          => $product->price, // snapshot
                    'qty'            => $prepared['qty'],
                    'discount'       => $prepared['discount'],
                    'note'           => $prepared['note'],
                    'subtotal'       => $prepared['subtotal'],
                ]);

                $product->decrement('stock', $prepared['qty']);

                StockMovement::create([
                    'product_id'   => $product->id,
                    'type'         => StockMovementType::Sale,
                    'quantity'     => -$prepared['qty'],
                    'note'         => "Terjual via {$transaction->invoice_number}",
                    'reference_id' => $transaction->id,
                    'created_by'   => $userId,
                ]);
            }

            // 5. Simpan pembayaran
            Payment::create([
                'transaction_id'  => $transaction->id,
                'method'          => $paymentMethod,
                'amount_received' => $amountReceived,
                'change_amount'   => $changeAmount,
            ]);

            return $transaction->load(['items', 'payment', 'cashier']);
        });
    }

    /**
     * Void transaksi: kembalikan stok, tandai voided, catat audit log.
     */
    public function void(Transaction $transaction, ?string $reason, int $voidedByUserId): Transaction
    {
        if ($transaction->status === TransactionStatus::Voided) {
            throw ValidationException::withMessages([
                'status' => ['Transaksi ini sudah pernah di-void sebelumnya'],
            ]);
        }

        return DB::transaction(function () use ($transaction, $reason, $voidedByUserId) {
            foreach ($transaction->items as $item) {
                $item->product()->increment('stock', $item->qty);

                StockMovement::create([
                    'product_id'   => $item->product_id,
                    'type'         => StockMovementType::VoidReturn,
                    'quantity'     => $item->qty,
                    'note'         => "Void transaksi {$transaction->invoice_number}",
                    'reference_id' => $transaction->id,
                    'created_by'   => $voidedByUserId,
                ]);
            }

            $transaction->update([
                'status'      => TransactionStatus::Voided,
                'voided_by'   => $voidedByUserId,
                'voided_at'   => now(),
                'void_reason' => $reason,
            ]);

            return $transaction->fresh(['items', 'payment', 'cashier', 'voidedByUser']);
        });
    }
}