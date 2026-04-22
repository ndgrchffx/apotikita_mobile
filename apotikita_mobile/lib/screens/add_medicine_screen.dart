/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final name = _nameController.text;
    final category = _categoryController.text;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (name.isEmpty || category.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua data dengan benar!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await Provider.of<MedicineProvider>(
      context,
      listen: false,
    ).addMedicine(name, category, price);

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pop(context); // Balik ke Dashboard setelah sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Obat berhasil ditambahkan!")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambah obat, cek koneksi/API!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Obat Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Obat",
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Harga",
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Obat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
