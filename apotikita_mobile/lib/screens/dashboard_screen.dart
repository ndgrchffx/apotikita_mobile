import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../services/api_service.dart';
import '../widgets/drug_info_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<MedicineProvider>(context, listen: false).getMedicines(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(dynamic price) {
    final p = int.tryParse(price.toString()) ?? 0;
    return 'Rp ${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yakin mau Logout?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sesi kamu akan berakhir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B5BDB),
                      side: const BorderSide(color: Color(0xFF3B5BDB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.logout();
                      if (mounted) {
                        Navigator.pop(ctx);
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ya, Keluar!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialog({dynamic medicine}) {
    final nameCtrl = TextEditingController(text: medicine?['name'] ?? '');
    final catCtrl = TextEditingController(text: medicine?['category'] ?? '');
    final priceCtrl = TextEditingController(
      text: medicine != null ? medicine['price'].toString() : '',
    );
    final isEdit = medicine != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5BDB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Obat' : 'Tambah Obat Baru',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: _inputDec('Nama Obat', Icons.medication),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catCtrl,
                decoration: _inputDec('Kategori', Icons.category),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDec('Harga', Icons.attach_money),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final category = catCtrl.text.trim();
                        final price = int.tryParse(priceCtrl.text) ?? 0;
                        if (name.isEmpty || category.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Isi semua data dengan benar!'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        final provider = Provider.of<MedicineProvider>(
                          context,
                          listen: false,
                        );
                        bool success;
                        if (isEdit) {
                          success = await provider.updateMedicine(
                            medicine['id'],
                            name,
                            category,
                            price,
                          );
                        } else {
                          success = await provider.addMedicine(
                            name,
                            category,
                            price,
                          );
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? isEdit
                                          ? 'Obat berhasil diupdate!'
                                          : 'Obat berhasil ditambahkan!'
                                    : 'Gagal menyimpan data!',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5BDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'UPDATE' : 'SIMPAN',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(dynamic medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Obat?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '"${medicine['name']}" akan dihapus permanen.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B5BDB),
                      side: const BorderSide(color: Color(0xFF3B5BDB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await Provider.of<MedicineProvider>(
                        context,
                        listen: false,
                      ).deleteMedicine(medicine['id']);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Obat berhasil dihapus!'
                                  : 'Gagal menghapus obat!',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ya, Hapus!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3B5BDB)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B5BDB), Color(0xFF7048E8)],
            ),
          ),
        ),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Apoti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'kita',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF74C0FC),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const DrugInfoDialog(),
              );
            },
            tooltip: 'Info Obat',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            color: const Color(0xFF3B5BDB),
            onRefresh: () => provider.getMedicines(),
            child: CustomScrollView(
              slivers: [
                // Stats Cards
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B5BDB), Color(0xFF7048E8)],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.inventory_2_outlined,
                            label: 'Total Produk',
                            value: '${provider.totalProducts}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            label: 'Harga Tertinggi',
                            value: _formatPrice(provider.highestPrice),
                            isPrice: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.search(val),
                        decoration: InputDecoration(
                          hintText: 'Cari nama obat atau kategori...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Header list
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Data Obat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B5BDB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${provider.medicines.length} item',
                            style: const TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Content: loading / error / data
                if (provider.state == MedicineState.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B5BDB),
                      ),
                    ),
                  )
                else if (provider.state == MedicineState.error)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 56,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal memuat data!\n${provider.errorMessage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.getMedicines(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5BDB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.medicines.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada data obat.',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final medicine = provider.medicines[index];
                        return _MedicineCard(
                          medicine: medicine,
                          formatPrice: _formatPrice,
                          onEdit: () => _showFormDialog(medicine: medicine),
                          onDelete: () => _showDeleteDialog(medicine),
                        );
                      }, childCount: provider.medicines.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF3B5BDB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Obat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 4,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPrice;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isPrice ? 13 : 22,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final dynamic medicine;
  final String Function(dynamic) formatPrice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.formatPrice,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Color(0xFF3B5BDB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine['name'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1a1a2e),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7048E8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          medicine['category'] ?? '-',
                          style: const TextStyle(
                            color: Color(0xFF7048E8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatPrice(medicine['price']),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade700,
                      side: BorderSide(color: Colors.amber.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
