class Medicine {
  final int id;
  final String name;
  final String category;
  final int price;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      // Cek ID: kalau null kasih 0, kalau string ubah ke int
      id: json['id'] == null
          ? 0
          : (json['id'] is int
                ? json['id']
                : int.tryParse(json['id'].toString()) ?? 0),

      // Cek Name: kalau null kasih string kosong
      name: json['name']?.toString() ?? 'Tidak ada nama',

      // Cek Category: kalau null kasih 'Umum'
      category: json['category']?.toString() ?? 'Umum',

      // Cek Price: kalau null kasih 0, kalau string ubah ke int
      price: json['price'] == null
          ? 0
          : (json['price'] is int
                ? json['price']
                : int.tryParse(json['price'].toString()) ?? 0),
    );
  }
}
