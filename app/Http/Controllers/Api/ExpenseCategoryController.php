<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExpenseCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class ExpenseCategoryController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $categories = ExpenseCategory::all();
        return $this->successResponse($categories, 'Data kategori pengeluaran berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $category = ExpenseCategory::create($validator->validated());
        return $this->successResponse($category, 'Kategori pengeluaran berhasil ditambahkan', 201);
    }

    public function show($id)
    {
        $category = ExpenseCategory::find($id);

        if (!$category) {
            return $this->errorResponse('Kategori pengeluaran tidak ditemukan', [], 404);
        }

        return $this->successResponse($category, 'Detail kategori pengeluaran berhasil diambil');
    }

    public function update(Request $request, $id)
    {
        $category = ExpenseCategory::find($id);

        if (!$category) {
            return $this->errorResponse('Kategori pengeluaran tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $category->update($validator->validated());
        return $this->successResponse($category, 'Kategori pengeluaran berhasil diupdate');
    }

    public function destroy($id)
    {
        $category = ExpenseCategory::find($id);

        if (!$category) {
            return $this->errorResponse('Kategori pengeluaran tidak ditemukan', [], 404);
        }

        if ($category->expenses()->exists()) {
            return $this->errorResponse(
                'Kategori tidak bisa dihapus karena masih memiliki data pengeluaran',
                [],
                400
            );
        }

        $category->delete();
        return $this->successResponse(null, 'Kategori pengeluaran berhasil dihapus');
    }
}