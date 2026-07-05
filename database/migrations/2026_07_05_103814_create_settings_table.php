<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('store_name')->default('Toko Saya');
            $table->string('store_address')->nullable();
            $table->string('store_phone')->nullable();
            $table->string('logo_path')->nullable();
            $table->timestamps();
        });

        DB::table('settings')->insert([
            'store_name' => 'Toko Saya',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};