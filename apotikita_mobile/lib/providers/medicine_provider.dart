import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum MedicineState { idle, loading, error }

class MedicineProvider extends ChangeNotifier {
  List<dynamic> _medicines = [];
  List<dynamic> _filtered = [];
  MedicineState _state = MedicineState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _medicines
        .map((m) => m['category'].toString())
        .toSet()
        .toList();
    cats.insert(0, 'Semua');
    return cats;
  }

  String _role = 'user'; // Default sebagai user
  String get role => _role;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }

  bool get isAdmin => _role == 'admin';

  List<dynamic> get medicines => _filtered;
  MedicineState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  int get totalProducts => _medicines.length;

  int get highestPrice {
    if (_medicines.isEmpty) return 0;
    return _medicines
        .map((m) => int.tryParse(m['price'].toString()) ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  List<dynamic> get topExpensiveMedicines {
    if (_medicines.isEmpty) return [];
    List<dynamic> sorted = List.from(_medicines);
    // Sort dari harga tertinggi ke terendah
    sorted.sort(
      (a, b) => (int.tryParse(b['price'].toString()) ?? 0).compareTo(
        int.tryParse(a['price'].toString()) ?? 0,
      ),
    );
    // Ambil 5 teratas
    return sorted.take(5).toList();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filtered = List.from(_medicines);
    } else {
      _filtered = _medicines.where((m) {
        final name = m['name'].toString().toLowerCase();
        final category = m['category'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    List<dynamic> base = category == 'Semua'
        ? List.from(_medicines)
        : _medicines
              .where((m) => m['category'].toString() == category)
              .toList();
    if (_searchQuery.isNotEmpty) {
      base = base.where((m) {
        final name = m['name'].toString().toLowerCase();
        final cat = m['category'].toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            cat.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _filtered = base;
    notifyListeners();
  }

  // get medicines
  Future<void> getMedicines() async {
    _state = MedicineState.loading;
    notifyListeners();
    try {
      final data = await ApiService.getMedicines();
      _medicines = data;
      _filtered = List.from(data);
      _state = MedicineState.idle;
    } catch (e) {
      _state = MedicineState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addMedicine(String name, String category, int price) async {
    final success = await ApiService.addMedicine({
      'name': name,
      'category': category,
      'price': price,
    });
    if (success) await getMedicines();
    return success;
  }

  Future<bool> updateMedicine(
    int id,
    String name,
    String category,
    int price,
  ) async {
    final success = await ApiService.updateMedicine(id, {
      'name': name,
      'category': category,
      'price': price,
    });
    if (success) await getMedicines();
    return success;
  }

  Future<bool> deleteMedicine(int id) async {
    final success = await ApiService.deleteMedicine(id);
    if (success) await getMedicines();
    return success;
  }
}
