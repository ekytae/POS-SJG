<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreStockMovementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => 'required|exists:products,id',
            // Hanya production_in & adjustment yang boleh diinput manual.
            // 'sale' dan 'void_return' murni hasil otomatis dari TransactionService.
            'type'       => 'required|in:production_in,adjustment',
            'quantity'   => 'required|integer|not_in:0',
            'note'       => 'nullable|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'type.in' => 'Tipe pergerakan stok manual hanya boleh production_in atau adjustment',
            'quantity.not_in' => 'Jumlah tidak boleh 0',
        ];
    }
}