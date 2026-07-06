<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\UnitController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\StockMovementController;
use App\Http\Controllers\Api\ExpenseCategoryController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\PrinterController;
use App\Http\Controllers\Api\UserController;

Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);

        // Master data: kasir boleh baca (butuh untuk transaksi), owner boleh CRUD penuh
        Route::apiResource('categories', CategoryController::class)->only(['index', 'show']);
        Route::apiResource('products', ProductController::class)->only(['index', 'show']);
        Route::apiResource('units', UnitController::class)->only(['index', 'show']);

        // Transaksi: kasir & owner sama-sama boleh (sesuai keputusan Step 2 - void bebas siapa saja)
        Route::apiResource('transactions', TransactionController::class)->only(['index', 'store', 'show']);
        Route::patch('/transactions/{id}/void', [TransactionController::class, 'void']);

        // Printer: milik masing-masing user, tidak perlu role-check khusus
        Route::apiResource('printers', PrinterController::class)->only(['index', 'store', 'update', 'destroy']);
        Route::patch('/printers/{id}/set-default', [PrinterController::class, 'setDefault']);

        // ==== Owner-only ====
        Route::middleware('owner')->group(function () {
            Route::apiResource('categories', CategoryController::class)->only(['store', 'update', 'destroy']);
            Route::apiResource('products', ProductController::class)->only(['store', 'update', 'destroy']);
            Route::apiResource('units', UnitController::class)->only(['store', 'update', 'destroy']);

            Route::apiResource('stock-movements', StockMovementController::class)->only(['index', 'store']);

            Route::apiResource('expense-categories', ExpenseCategoryController::class);
            Route::apiResource('expenses', ExpenseController::class);

            Route::get('/dashboard/summary', [DashboardController::class, 'summary']);

            Route::get('/reports/sales', [ReportController::class, 'sales']);
            Route::get('/reports/best-selling-products', [ReportController::class, 'bestSellingProducts']);
            Route::get('/reports/expenses', [ReportController::class, 'expenses']);
            Route::get('/reports/stock-card', [ReportController::class, 'stockCard']);

            Route::get('/settings', [SettingController::class, 'show']);
            Route::put('/settings', [SettingController::class, 'update']);

            Route::get('/users', [UserController::class, 'index']);
            Route::post('/users', [UserController::class, 'store']);
            Route::put('/users/{id}', [UserController::class, 'update']);
            Route::patch('/users/{id}/toggle-active', [UserController::class, 'toggleActive']);
        });
    });
});