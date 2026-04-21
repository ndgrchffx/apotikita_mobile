<?php

namespace App\Http\Controllers;

use App\Models\Medicine;
use Illuminate\Http\Request;

class MedicineController extends Controller
{
    // Menampilkan semua data (Read)
    public function index()
    {
        return response()->json(Medicine::all());
    }

    // Menambah data (Create)
    public function store(Request $request)
    {
        // Validasi input
        $request->validate([
            'name' => 'required',
            'category' => 'required',
            'price' => 'required|numeric',
        ]);

        // Simpan data
        $medicine = Medicine::create($request->all());

        return response()->json([
            'message' => 'Obat berhasil ditambahkan!',
            'data' => $medicine
        ], 201);
    }

    // Menampilkan satu data detail
    public function show(Medicine $medicine)
    {
        return response()->json($medicine);
    }

    // Mengubah data (Update)
    public function update(Request $request, $id)
    {
        $medicine = Medicine::find($id);

        if (!$medicine) {
            return response()->json(['message' => 'Obat tidak ditemukan'], 404);
        }

        $medicine->update($request->all());
        return response()->json($medicine);
    }

    // Menghapus data (Delete)
    public function destroy(Medicine $medicine)
    {
        $medicine->delete();
        return response()->json(['message' => 'Data dihapus']);
    }
}
