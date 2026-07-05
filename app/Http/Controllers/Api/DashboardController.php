<?php

namespace App\Http\Controllers\Api;

use App\Enums\TransactionStatus;
use App\Http\Controllers\Controller;
use App\Models\Expense;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use App\Traits\ApiResponse;
use Illuminate\Support\Carbon;

class DashboardController extends Controller
{
    use ApiResponse;

    public function summary()
    {
        $today = Carbon::today();
        $startOfMonth = Carbon::now()->startOfMonth();
        $endOfMonth = Carbon::now()->endOfMonth();

        $completedQuery = fn () => Transaction::where('status', TransactionStatus::Completed);

        // Omzet hari ini
        $revenueToday = $completedQuery()
            ->whereDate('created_at', $today)
            ->sum('total');

        // Omzet bulan ini
        $revenueThisMonth = $completedQuery()
            ->whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->sum('total');

        // Jumlah transaksi hari ini
        $transactionCountToday = $completedQuery()
            ->whereDate('created_at', $today)
            ->count();

        // Produk terjual hari ini (total qty dari transaction_details)
        $productsSoldToday = TransactionDetail::whereHas('transaction', function ($query) use ($today) {
            $query->where('status', TransactionStatus::Completed)
                ->whereDate('created_at', $today);
        })->sum('qty');

        // Pengeluaran bulan ini
        $expensesThisMonth = Expense::whereBetween('date', [$startOfMonth, $endOfMonth])
            ->sum('amount');

        // Profit sederhana: omzet bulan ini - pengeluaran bulan ini
        // (belum dikurangi cost_price, sesuai keputusan Step 1 - cost_price ditunda)
        $profitSimple = $revenueThisMonth - $expensesThisMonth;

        // Grafik penjualan 7 hari terakhir
        $salesChart = $this->getSalesChart();

        return $this->successResponse([
            'revenue_today'            => (float) $revenueToday,
            'revenue_this_month'       => (float) $revenueThisMonth,
            'transaction_count_today'  => $transactionCountToday,
            'products_sold_today'      => (int) $productsSoldToday,
            'expenses_this_month'      => (float) $expensesThisMonth,
            'profit_simple'            => (float) $profitSimple,
            'sales_chart'              => $salesChart,
        ], 'Ringkasan dashboard berhasil diambil');
    }

    private function getSalesChart(int $days = 7): array
    {
        $startDate = Carbon::today()->subDays($days - 1);

        $rawData = Transaction::where('status', TransactionStatus::Completed)
            ->whereDate('created_at', '>=', $startDate)
            ->selectRaw('DATE(created_at) as date, SUM(total) as total')
            ->groupBy('date')
            ->pluck('total', 'date');

        // Isi tanggal yang tidak ada transaksi dengan 0, supaya grafik tidak bolong
        $chart = [];
        for ($i = 0; $i < $days; $i++) {
            $date = $startDate->copy()->addDays($i)->toDateString();
            $chart[] = [
                'date'  => $date,
                'total' => (float) ($rawData[$date] ?? 0),
            ];
        }

        return $chart;
    }
}