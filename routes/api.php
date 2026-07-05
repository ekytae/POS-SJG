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

Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);

        Route::apiResource('categories', CategoryController::class);
        Route::apiResource('products', ProductController::class);
        Route::apiResource('units', UnitController::class);

        Route::apiResource('transactions', TransactionController::class)->only(['index', 'store', 'show']);
        Route::patch('/transactions/{id}/void', [TransactionController::class, 'void']);

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

        Route::apiResource('printers', PrinterController::class)->only(['index', 'store', 'update', 'destroy']);
        Route::patch('/printers/{id}/set-default', [PrinterController::class, 'setDefault']);
    });
});