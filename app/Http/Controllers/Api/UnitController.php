<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Unit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class UnitController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $units = Unit::all();
        return $this->successResponse($units, 'Data satuan berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $unit = Unit::create($validator->validated());
        return $this->successResponse($unit, 'Satuan berhasil ditambahkan', 201);
    }

    public function show($id)
    {
        $unit = Unit::find($id);

        if (!$unit) {
            return $this->errorResponse('Satuan tidak ditemukan', [], 404);
        }

        return $this->successResponse($unit, 'Detail satuan berhasil diambil');
    }

    public function update(Request $request, $id)
    {
        $unit = Unit::find($id);

        if (!$unit) {
            return $this->errorResponse('Satuan tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $unit->update($validator->validated());
        return $this->successResponse($unit, 'Satuan berhasil diupdate');
    }

    public function destroy($id)
    {
        $unit = Unit::find($id);

        if (!$unit) {
            return $this->errorResponse('Satuan tidak ditemukan', [], 404);
        }

        if ($unit->products()->exists()) {
            return $this->errorResponse(
                'Satuan tidak bisa dihapus karena masih digunakan oleh produk',
                [],
                400
            );
        }

        $unit->delete();
        return $this->successResponse(null, 'Satuan berhasil dihapus');
    }
}