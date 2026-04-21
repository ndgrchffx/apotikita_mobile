<?php

use App\Http\Controllers\MedicineController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Public: Login nggak perlu token (karena mau minta token)
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);

// Protected: Semua CRUD obat WAJIB pakai token
Route::middleware('auth:api')->group(function () {
    Route::get('medicines', [MedicineController::class, 'index']);
    Route::post('medicines', [MedicineController::class, 'store']);
    Route::get('medicines/{medicine}', [MedicineController::class, 'show']);
    Route::put('medicines/{medicine}', [MedicineController::class, 'update']);
    Route::delete('medicines/{medicine}', [MedicineController::class, 'destroy']);

    Route::post('auth/refresh', [AuthController::class, 'refresh']);
});
