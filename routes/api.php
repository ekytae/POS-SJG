<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    
    // Nanti endpoint yang butuh auth masuk ke dalam middleware ini
    Route::middleware('auth:sanctum')->group(function () {
        // Route::post('/logout', [AuthController::class, 'logout']);
        // Route::get('/me', [AuthController::class, 'me']);
    });
});