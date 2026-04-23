<?php

use App\Http\Controllers\MedicineController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Protected: Login wajib pakai token
Route::middleware('auth:api')->group(function () {

    // SEMUA BISA: Cuma liat daftar dan detail obat
    Route::get('medicines', [MedicineController::class, 'index']);
    Route::get('medicines/{medicine}', [MedicineController::class, 'show']);

    // KHUSUS ADMIN: Tambah, Update, Hapus
    Route::middleware('role:admin')->group(function () {
        Route::post('medicines', [MedicineController::class, 'store']);
        Route::put('medicines/{medicine}', [MedicineController::class, 'update']);
        Route::delete('medicines/{medicine}', [MedicineController::class, 'destroy']);
    });

    Route::post('auth/refresh', [AuthController::class, 'refresh']);
});
