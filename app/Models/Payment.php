<?php

namespace App\Models;

use App\Enums\PaymentMethod;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    protected $fillable = [
        'transaction_id',
        'method',
        'amount_received',
        'change_amount',
    ];

    protected function casts(): array
    {
        return [
            'method' => PaymentMethod::class,
            'amount_received' => 'decimal:2',
            'change_amount' => 'decimal:2',
        ];
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }
}