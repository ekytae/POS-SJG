<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'store_name',
        'store_address',
        'store_phone',
        'logo_path',
    ];

    /**
     * Karena settings cuma 1 baris (single-row table),
     * helper ini memudahkan ambil datanya tanpa perlu tahu ID.
     */
    public static function current(): self
    {
        return static::firstOrCreate(['id' => 1], ['store_name' => 'Toko Saya']);
    }
}