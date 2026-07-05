<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController; // Jangan lupa import controller-nya

Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
        
        // CRUD Category Route
        Route::apiResource('categories', CategoryController::class);
        Route::apiResource('products', ProductController::class);
    });
});