<?php

use App\Http\Controllers\MedicineController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// --- 1. PUBLIK (Taruh paling atas, JANGAN di dalam middleware) ---
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);

// --- 2. PROTECTED (Harus pakai Token) ---
Route::middleware('auth:api')->group(function () {

    // Semua User (Admin & Biasa) bisa liat obat
    Route::get('medicines', [MedicineController::class, 'index']);
    Route::get('medicines/{id}', [MedicineController::class, 'show']);

    // --- 3. KHUSUS ADMIN ---
    Route::middleware('role:admin')->group(function () {
        Route::post('medicines', [MedicineController::class, 'store']);
        Route::put('medicines/{id}', [MedicineController::class, 'update']);
        Route::delete('medicines/{id}', [MedicineController::class, 'destroy']);
    });

    Route::post('auth/refresh', [AuthController::class, 'refresh']);
});
