<?php

namespace App\Services;

use App\Enums\StockMovementType;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class StockMovementService
{
    /**
     * Catat pergerakan stok manual (production_in / adjustment).
     * quantity: positif untuk nambah stok, negatif untuk mengurangi (khusus adjustment).
     */
    public function record(array $data, int $userId): StockMovement
    {
        return DB::transaction(function () use ($data, $userId) {
            $product = Product::lockForUpdate()->find($data['product_id']);

            if (!$product) {
                throw ValidationException::withMessages([
                    'product_id' => ['Produk tidak ditemukan'],
                ]);
            }

            $type = StockMovementType::from($data['type']);
            $quantity = $data['quantity'];

            // production_in wajib positif — kalau mau kurangi stok manual, pakai adjustment
            if ($type === StockMovementType::ProductionIn && $quantity < 0) {
                throw ValidationException::withMessages([
                    'quantity' => ['Stok masuk (produksi) harus bernilai positif'],
                ]);
            }

            $newStock = $product->stock + $quantity;

            if ($newStock < 0) {
                throw ValidationException::withMessages([
                    'quantity' => ["Stok tidak cukup untuk penyesuaian ini. Stok saat ini: {$product->stock}"],
                ]);
            }

            $product->update(['stock' => $newStock]);

            return StockMovement::create([
                'product_id' => $product->id,
                'type'       => $type,
                'quantity'   => $quantity,
                'note'       => $data['note'] ?? null,
                'created_by' => $userId,
            ])->load(['product', 'creator']);
        });
    }
}