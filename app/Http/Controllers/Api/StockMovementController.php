<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreStockMovementRequest;
use App\Models\StockMovement;
use App\Services\StockMovementService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class StockMovementController extends Controller
{
    use ApiResponse;

    public function __construct(protected StockMovementService $stockMovementService)
    {
    }

    public function index(Request $request)
    {
        $query = StockMovement::with(['product', 'creator'])->latest();

        if ($request->filled('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $movements = $query->paginate($request->get('per_page', 20));

        return $this->successResponse($movements, 'Riwayat pergerakan stok berhasil diambil');
    }

    public function store(StoreStockMovementRequest $request)
    {
        try {
            $movement = $this->stockMovementService->record(
                $request->validated(),
                $request->user()->id
            );

            return $this->successResponse($movement, 'Pergerakan stok berhasil dicatat', 201);
        } catch (ValidationException $e) {
            return $this->errorResponse('Gagal mencatat pergerakan stok', $e->errors(), 422);
        }
    }
}