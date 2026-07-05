<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class CategoryController extends Controller
{
    use ApiResponse;

    // GET: Ambil semua data kategori
    public function index()
    {
        $categories = Category::all();
        return $this->successResponse($categories, 'Data kategori berhasil diambil');
    }

    // POST: Tambah kategori baru
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            // Tambahkan validasi lain jika ada kolom deskripsi, dll
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $category = Category::create($request->all());
        return $this->successResponse($category, 'Kategori berhasil ditambahkan', 201);
    }

    // GET: Ambil detail 1 kategori
    public function show($id)
    {
        $category = Category::find($id);
        
        if (!$category) {
            return $this->errorResponse('Kategori tidak ditemukan', [], 404);
        }

        return $this->successResponse($category, 'Detail kategori berhasil diambil');
    }

    // PUT/PATCH: Update kategori
    public function update(Request $request, $id)
    {
        $category = Category::find($id);
        
        if (!$category) {
            return $this->errorResponse('Kategori tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $category->update($request->all());
        return $this->successResponse($category, 'Kategori berhasil diupdate');
    }

    // DELETE: Hapus kategori
    public function destroy($id)
    {
        $category = Category::find($id);
        
        if (!$category) {
            return $this->errorResponse('Kategori tidak ditemukan', [], 404);
        }

        // Cek apakah ada produk yang pakai kategori ini sebelum dihapus (Opsional tapi direkomendasikan)
        // if ($category->products()->count() > 0) {
        //     return $this->errorResponse('Kategori tidak bisa dihapus karena masih digunakan oleh produk', [], 400);
        // }

        $category->delete();
        return $this->successResponse(null, 'Kategori berhasil dihapus');
    }
}