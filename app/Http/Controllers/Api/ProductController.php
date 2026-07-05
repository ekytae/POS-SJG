<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class ProductController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Product::with(['category', 'unit']);

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        $products = $query->get();

        return $this->successResponse($products, 'Data produk berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category_id' => 'required|exists:categories,id',
            'unit_id'     => 'required|exists:units,id',
            'name'        => 'required|string|max:255',
            'price'       => 'required|numeric|min:0',
            'cost_price'  => 'nullable|numeric|min:0',
            'stock'       => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $product = Product::create($validator->validated());
        $product->load(['category', 'unit']);

        return $this->successResponse($product, 'Produk berhasil ditambahkan', 201);
    }

    public function show($id)
    {
        $product = Product::with(['category', 'unit'])->find($id);

        if (!$product) {
            return $this->errorResponse('Produk tidak ditemukan', [], 404);
        }

        return $this->successResponse($product, 'Detail produk berhasil diambil');
    }

    public function update(Request $request, $id)
    {
        $product = Product::find($id);

        if (!$product) {
            return $this->errorResponse('Produk tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'category_id' => 'sometimes|exists:categories,id',
            'unit_id'     => 'sometimes|exists:units,id',
            'name'        => 'sometimes|string|max:255',
            'price'       => 'sometimes|numeric|min:0',
            'cost_price'  => 'nullable|numeric|min:0',
            'stock'       => 'sometimes|integer|min:0',
            'is_active'   => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $product->update($validator->validated());
        $product->load(['category', 'unit']);

        return $this->successResponse($product, 'Produk berhasil diupdate');
    }

    public function destroy($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return $this->errorResponse('Produk tidak ditemukan', [], 404);
        }

        // Soft-disable, bukan hard delete — sesuai keputusan Step 5
        // supaya riwayat transaksi lama tidak kehilangan relasi produk
        $product->update(['is_active' => false]);

        return $this->successResponse(null, 'Produk berhasil dinonaktifkan');
    }
}