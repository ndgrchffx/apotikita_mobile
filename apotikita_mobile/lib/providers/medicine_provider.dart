import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum MedicineState { idle, loading, error }

class MedicineProvider extends ChangeNotifier {
  // Ganti jadi dynamic biar fleksibel nerima data dari Laravel lu
  List<dynamic> _medicines = [];
  MedicineState _state = MedicineState.idle;
  String _errorMessage = '';

  List<dynamic> get medicines => _medicines;
  MedicineState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> getMedicines() async {
    _state = MedicineState.loading;
    notifyListeners();
    try {
      final data = await ApiService.getMedicines();
      // Langsung masukin data dari API tanpa di-map ke Model dulu
      _medicines = data;
      _state = MedicineState.idle;
    } catch (e) {
      _state = MedicineState.error;
      _errorMessage = e.toString();
      print("Error ambil data: $e"); // Liat di console error-nya apa
    }
    notifyListeners();
  }

  // Fungsi tambah & hapus tetep sama
  Future<bool> addMedicine(String name, String category, int price) async {
    final success = await ApiService.addMedicine({
      'name': name,
      'category': category,
      'price': price,
    });
    if (success) await getMedicines();
    return success;
  }
}
