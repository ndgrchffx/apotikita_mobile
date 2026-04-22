import 'package:flutter/material.dart';
import '../services/drug_info_service.dart';

class DrugInfoDialog extends StatefulWidget {
  const DrugInfoDialog({super.key});

  @override
  State<DrugInfoDialog> createState() => _DrugInfoDialogState();
}

class _DrugInfoDialogState extends State<DrugInfoDialog> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, String>? _drugInfo;
  bool _isLoading = false;
  bool _notFound = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _notFound = false;
      _hasSearched = true;
      _drugInfo = null;
    });

    final result = await DrugInfoService.getDrugInfo(query);

    setState(() {
      _isLoading = false;
      if (result == null) {
        _notFound = true;
      } else {
        _drugInfo = result;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF3B5BDB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Obat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B5BDB),
                        ),
                      ),
                      Text(
                        'Data dari OpenFDA • Diterjemahkan otomatis',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama obat (misal: Paracetamol)...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B5BDB),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cari',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Flexible(child: SingleChildScrollView(child: _buildContent())),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Belum search
    if (!_hasSearched) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.medication_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Masukkan nama obat untuk\nmencari informasi lengkapnya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Loading
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF3B5BDB)),
              SizedBox(height: 16),
              Text(
                'Mencari & menerjemahkan...\nMohon tunggu sebentar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Tidak ditemukan
    if (_notFound) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.red),
              SizedBox(height: 12),
              Text(
                'Obat tidak ditemukan.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Coba nama lain atau nama generiknya\n(dalam Bahasa Inggris).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Hasil ditemukan
    if (_drugInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info header obat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B5BDB), Color(0xFF7048E8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.medication, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _drugInfo!['brand_name'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Generik: ${_drugInfo!['generic_name'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Produsen: ${_drugInfo!['manufacturer'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Info sections
          _InfoSection(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: 'Indikasi & Kegunaan',
            content: _drugInfo!['indication'] ?? '-',
          ),
          _InfoSection(
            icon: Icons.warning_amber_outlined,
            iconColor: Colors.orange,
            title: 'Efek Samping',
            content: _drugInfo!['side_effect'] ?? '-',
          ),
          _InfoSection(
            icon: Icons.dangerous_outlined,
            iconColor: Colors.red,
            title: 'Peringatan',
            content: _drugInfo!['warnings'] ?? '-',
          ),
          _InfoSection(
            icon: Icons.medical_information_outlined,
            iconColor: const Color(0xFF3B5BDB),
            title: 'Dosis & Cara Penggunaan',
            content: _drugInfo!['dosage'] ?? '-',
          ),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data dari OpenFDA (FDA Amerika). Selalu konsultasikan dengan dokter atau apoteker.',
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
