<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Printer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Traits\ApiResponse;

class PrinterController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $printers = Printer::where('user_id', $request->user()->id)->get();
        return $this->successResponse($printers, 'Data printer berhasil diambil');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'        => 'required|string|max:255',
            'mac_address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $printer = Printer::create([
            ...$validator->validated(),
            'user_id'    => $request->user()->id,
            'is_default' => false,
        ]);

        return $this->successResponse($printer, 'Printer berhasil ditambahkan', 201);
    }

    public function update(Request $request, $id)
    {
        $printer = Printer::where('user_id', $request->user()->id)->find($id);

        if (!$printer) {
            return $this->errorResponse('Printer tidak ditemukan', [], 404);
        }

        $validator = Validator::make($request->all(), [
            'name'        => 'sometimes|string|max:255',
            'mac_address' => 'sometimes|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', $validator->errors(), 422);
        }

        $printer->update($validator->validated());
        return $this->successResponse($printer, 'Printer berhasil diupdate');
    }

    public function destroy(Request $request, $id)
    {
        $printer = Printer::where('user_id', $request->user()->id)->find($id);

        if (!$printer) {
            return $this->errorResponse('Printer tidak ditemukan', [], 404);
        }

        $printer->delete();
        return $this->successResponse(null, 'Printer berhasil dihapus');
    }

    public function setDefault(Request $request, $id)
    {
        $printer = Printer::where('user_id', $request->user()->id)->find($id);

        if (!$printer) {
            return $this->errorResponse('Printer tidak ditemukan', [], 404);
        }

        DB::transaction(function () use ($printer, $request) {
            // Pastikan cuma 1 printer default per user
            Printer::where('user_id', $request->user()->id)
                ->where('id', '!=', $printer->id)
                ->update(['is_default' => false]);

            $printer->update(['is_default' => true]);
        });

        return $this->successResponse($printer->fresh(), 'Printer berhasil dijadikan default');
    }
}