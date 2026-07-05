<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Models\Transaction;
use App\Services\TransactionService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TransactionController extends Controller
{
    use ApiResponse;

    public function __construct(protected TransactionService $transactionService)
    {
    }

    public function index(Request $request)
    {
        $query = Transaction::with(['cashier'])
            ->latest();

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        if ($request->filled('search')) {
            $query->where('invoice_number', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $transactions = $query->paginate($request->get('per_page', 20));

        return $this->successResponse($transactions, 'Data transaksi berhasil diambil');
    }

    public function store(StoreTransactionRequest $request)
    {
        try {
            $transaction = $this->transactionService->create(
                $request->validated(),
                $request->user()->id
            );

            return $this->successResponse($transaction, 'Transaksi berhasil disimpan', 201);
        } catch (ValidationException $e) {
            return $this->errorResponse('Transaksi gagal', $e->errors(), 422);
        }
    }

    public function show($id)
    {
        $transaction = Transaction::with(['items', 'payment', 'cashier', 'voidedByUser'])->find($id);

        if (!$transaction) {
            return $this->errorResponse('Transaksi tidak ditemukan', [], 404);
        }

        return $this->successResponse($transaction, 'Detail transaksi berhasil diambil');
    }

    public function void(Request $request, $id)
    {
        $transaction = Transaction::with('items')->find($id);

        if (!$transaction) {
            return $this->errorResponse('Transaksi tidak ditemukan', [], 404);
        }

        try {
            $voided = $this->transactionService->void(
                $transaction,
                $request->input('reason'),
                $request->user()->id
            );

            return $this->successResponse($voided, 'Transaksi berhasil di-void');
        } catch (ValidationException $e) {
            return $this->errorResponse('Void gagal', $e->errors(), 422);
        }
    }
}