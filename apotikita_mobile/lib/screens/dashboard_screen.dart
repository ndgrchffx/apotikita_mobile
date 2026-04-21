import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

// NAMA CLASS HARUS DashboardScreen, BUKAN AddMedicineScreen!
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data pas halaman dibuka
    Future.microtask(
      () =>
          Provider.of<MedicineProvider>(context, listen: false).getMedicines(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Apotikita"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.state == MedicineState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicines.isEmpty) {
            return const Center(child: Text("Belum ada data obat."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.medicines.length,
            itemBuilder: (context, index) {
              final medicine = provider.medicines[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(medicine.name),
                  subtitle: Text(medicine.category),
                  trailing: Text("Rp ${medicine.price}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-medicine'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
