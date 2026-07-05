<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expense;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class ExpenseController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Expense::with(['category', 'creator'])->latest('date');

        if ($request->filled('date_from')) {
            $query->whereDate('date', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('date', '<=', $request->date_to);
        }

        if ($request->filled('expense_category_id')) {
            $query->where('expense_category_id', $request->expense_category_id);
        }

        $expenses = $query->paginate($request->get('per_page', 20));

        return $this->successResponse($expenses, 'Data pengeluaran berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'expense_category_id' => 'required|exists:expense_categories,id',
            'amount'               => 'required|numeric|min:0',
            'description'          => 'nullable|string|max:255',
            'date'                 => 'required|date',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $expense = Expense::create([
            ...$validator->validated(),
            'created_by' => $request->user()->id, // diisi server, bukan dari input client
        ]);

        $expense->load(['category', 'creator']);

        return $this->successResponse($expense, 'Pengeluaran berhasil dicatat', 201);
    }

    public function show($id)
    {
        $expense = Expense::with(['category', 'creator'])->find($id);

        if (!$expense) {
            return $this->errorResponse('Pengeluaran tidak ditemukan', [], 404);
        }

        return $this->successResponse($expense, 'Detail pengeluaran berhasil diambil');
    }

    public function update(Request $request, $id)
    {
        $expense = Expense::find($id);

        if (!$expense) {
            return $this->errorResponse('Pengeluaran tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'expense_category_id' => 'sometimes|exists:expense_categories,id',
            'amount'               => 'sometimes|numeric|min:0',
            'description'          => 'nullable|string|max:255',
            'date'                 => 'sometimes|date',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $expense->update($validator->validated());
        $expense->load(['category', 'creator']);

        return $this->successResponse($expense, 'Pengeluaran berhasil diupdate');
    }

    public function destroy($id)
    {
        $expense = Expense::find($id);

        if (!$expense) {
            return $this->errorResponse('Pengeluaran tidak ditemukan', [], 404);
        }

        $expense->delete();
        return $this->successResponse(null, 'Pengeluaran berhasil dihapus');
    }
}