<?php

use App\Http\Controllers\MedicineController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// 1. PUBLIC ROUTES (Login harus bisa diakses!)
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);

// 2. PROTECTED ROUTES
Route::middleware('auth:api')->group(function () {

    // Semua yang punya token bisa liat daftar obat
    Route::get('medicines', [MedicineController::class, 'index']);
    Route::get('medicines/{id}', [MedicineController::class, 'show']);

    // 3. ROLE CHECK (Admin Only)
    Route::middleware('role:admin')->group(function () {
        Route::post('medicines', [MedicineController::class, 'store']);
        Route::put('medicines/{id}', [MedicineController::class, 'update']);
        Route::delete('medicines/{id}', [MedicineController::class, 'destroy']);
    });

    Route::post('auth/refresh', [AuthController::class, 'refresh']);
});
