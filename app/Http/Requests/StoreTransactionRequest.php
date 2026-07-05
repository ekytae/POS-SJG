<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Semua user yang sudah login (kasir/owner) boleh bikin transaksi
    }

    public function rules(): array
    {
        return [
            'items'                    => 'required|array|min:1',
            'items.*.product_id'       => 'required|exists:products,id',
            'items.*.qty'              => 'required|integer|min:1',
            'items.*.discount'         => 'nullable|numeric|min:0',
            'items.*.note'             => 'nullable|string|max:255',

            'discount'                 => 'nullable|numeric|min:0',

            'payment.method'           => 'required|in:cash,qris,transfer,ewallet',
            'payment.amount_received'  => 'required_if:payment.method,cash|nullable|numeric|min:0',

            'customer_phone'           => 'nullable|string|max:20',
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Keranjang tidak boleh kosong',
            'items.*.product_id.exists' => 'Produk tidak ditemukan',
            'payment.amount_received.required_if' => 'Nominal uang diterima wajib diisi untuk pembayaran cash',
        ];
    }
}