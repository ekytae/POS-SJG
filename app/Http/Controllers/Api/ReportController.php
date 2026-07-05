<?php

namespace App\Http\Controllers\Api;

use App\Enums\StockMovementType;
use App\Enums\TransactionStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\ReportDateRangeRequest;
use App\Models\Expense;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use App\Traits\ApiResponse;
use Illuminate\Support\Carbon;

class ReportController extends Controller
{
    use ApiResponse;

    /**
     * Laporan penjualan: total omzet per hari dalam rentang tanggal,
     * plus ringkasan keseluruhan.
     */
    public function sales(ReportDateRangeRequest $request)
    {
        [$from, $to] = $this->parseRange($request);

        $transactions = Transaction::where('status', TransactionStatus::Completed)
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('DATE(created_at) as date, SUM(total) as total, COUNT(*) as transaction_count')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $summary = [
            'total_revenue'      => (float) $transactions->sum('total'),
            'total_transactions' => (int) $transactions->sum('transaction_count'),
        ];

        return $this->successResponse([
            'summary' => $summary,
            'details' => $transactions,
        ], 'Laporan penjualan berhasil diambil');
    }

    /**
     * Produk terlaris: total qty & omzet per produk, diurutkan dari terlaris.
     */
    public function bestSellingProducts(ReportDateRangeRequest $request)
    {
        [$from, $to] = $this->parseRange($request);

        $products = TransactionDetail::whereHas('transaction', function ($query) use ($from, $to) {
                $query->where('status', TransactionStatus::Completed)
                    ->whereBetween('created_at', [$from, $to]);
            })
            ->selectRaw('product_id, product_name, SUM(qty) as total_qty, SUM(subtotal) as total_revenue')
            ->groupBy('product_id', 'product_name')
            ->orderByDesc('total_qty')
            ->get();

        return $this->successResponse($products, 'Laporan produk terlaris berhasil diambil');
    }

    /**
     * Laporan pengeluaran: detail per transaksi pengeluaran + breakdown per kategori.
     */
    public function expenses(ReportDateRangeRequest $request)
    {
        [$from, $to] = $this->parseRange($request);

        $expenses = Expense::with('category')
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->orderBy('date')
            ->get();

        $byCategory = $expenses->groupBy('category.name')
            ->map(fn ($items) => (float) $items->sum('amount'))
            ->sortDesc()
            ->values()
            ->all();

        $byCategoryNamed = $expenses->groupBy(fn ($e) => $e->category->name ?? 'Tanpa Kategori')
            ->map(fn ($items, $categoryName) => [
                'category' => $categoryName,
                'total'    => (float) $items->sum('amount'),
            ])
            ->values();

        return $this->successResponse([
            'summary' => [
                'total_expenses' => (float) $expenses->sum('amount'),
            ],
            'by_category' => $byCategoryNamed,
            'details'      => $expenses,
        ], 'Laporan pengeluaran berhasil diambil');
    }

    /**
     * Kartu stok: riwayat pergerakan stok 1 produk dalam rentang tanggal,
     * plus saldo awal & saldo akhir.
     */
    public function stockCard(ReportDateRangeRequest $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        [$from, $to] = $this->parseRange($request);

        $product = Product::findOrFail($request->product_id);

        // Saldo awal = stok saat ini dikurangi semua movement dalam rentang (mundur dari sekarang)
        $movementsInRange = StockMovement::where('product_id', $product->id)
            ->whereBetween('created_at', [$from, $to])
            ->orderBy('created_at')
            ->get();

        $movementsAfterRange = StockMovement::where('product_id', $product->id)
            ->where('created_at', '>', $to)
            ->sum('quantity');

        $endingStock = $product->stock - $movementsAfterRange;
        $openingStock = $endingStock - $movementsInRange->sum('quantity');

        return $this->successResponse([
            'product' => [
                'id'   => $product->id,
                'name' => $product->name,
            ],
            'opening_stock' => $openingStock,
            'ending_stock'  => $endingStock,
            'movements'     => $movementsInRange,
        ], 'Kartu stok berhasil diambil');
    }

    private function parseRange(ReportDateRangeRequest $request): array
    {
        $from = Carbon::parse($request->from)->startOfDay();
        $to = Carbon::parse($request->to)->endOfDay();

        return [$from, $to];
    }
}