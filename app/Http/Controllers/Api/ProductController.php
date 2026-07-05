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

    public function index()
    {
        // Eager load relasi category
        $products = Product::with('category')->get();
        return $this->successResponse($products, 'Data produk berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category_id' => 'required|exists:categories,id', // Validasi id kategori harus ada di DB
            'name'        => 'required|string|max:255',
            'price'       => 'required|numeric|min:0',
            'stock'       => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $product = Product::create($request->all());
        return $this->successResponse($product, 'Produk berhasil ditambahkan', 201);
    }

    public function show($id)
    {
        $product = Product::with('category')->find($id);
        
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
            'name'        => 'sometimes|string|max:255',
            'price'       => 'sometimes|numeric|min:0',
            'stock'       => 'sometimes|integer|min:0',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $product->update($request->all());
        return $this->successResponse($product, 'Produk berhasil diupdate');
    }

    public function destroy($id)
    {
        $product = Product::find($id);
        
        if (!$product) {
            return $this->errorResponse('Produk tidak ditemukan', [], 404);
        }

        $product->delete();
        return $this->successResponse(null, 'Produk berhasil dihapus');
    }
}