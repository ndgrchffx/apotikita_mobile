import 'dart:convert';
import 'package:http/http.dart' as http;

class DrugInfoService {
  static const String _fdaBaseUrl = 'https://api.fda.gov/drug/label.json';
  static const String _translateUrl = 'https://api.mymemory.translated.net/get';

  // Translate teks dari EN ke ID
  static Future<String> translate(String text) async {
    if (text.isEmpty) return '-';
    try {
      final trimmed = text.length > 400 ? '${text.substring(0, 400)}...' : text;
      final uri = Uri.parse(
        '$_translateUrl?q=${Uri.encodeComponent(trimmed)}&langpair=en|id',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['responseData']['translatedText'] ?? trimmed;
      }
      return trimmed;
    } catch (e) {
      return text;
    }
  }

  // Ambil info obat dari OpenFDA
  static Future<Map<String, String>?> getDrugInfo(String drugName) async {
    try {
      // Cari pakai generic name dulu (lebih akurat)
      var uri = Uri.parse(
        '$_fdaBaseUrl?search=openfda.generic_name:"$drugName"&limit=1',
      );
      var response = await http.get(uri);

      // Kalau tidak ketemu, coba brand name
      if (response.statusCode != 200) {
        uri = Uri.parse(
          '$_fdaBaseUrl?search=openfda.brand_name:"$drugName"&limit=1',
        );
        response = await http.get(uri);
      }

      // Kalau masih tidak ketemu, coba search lebih luas
      if (response.statusCode != 200) {
        uri = Uri.parse('$_fdaBaseUrl?search=$drugName&limit=1');
        response = await http.get(uri);
      }

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final results = data['results'] as List;
      if (results.isEmpty) return null;

      final drug = results[0];
      final openFda = drug['openfda'] ?? {};

      String brandName = _getFirst(openFda['brand_name']) ?? drugName;
      String genericName = _getFirst(openFda['generic_name']) ?? '-';
      String manufacturer = _getFirst(openFda['manufacturer_name']) ?? '-';
      String indication = _getFirst(drug['indications_and_usage']) ?? '';
      String sideEffect = _getFirst(drug['adverse_reactions']) ?? '';
      String warnings = _getFirst(drug['warnings']) ?? '';
      String dosage = _getFirst(drug['dosage_and_administration']) ?? '';

      // Translate ke Bahasa Indonesia secara paralel
      final translated = await Future.wait([
        translate(indication),
        translate(sideEffect),
        translate(warnings),
        translate(dosage),
      ]);

      return {
        'brand_name': brandName,
        'generic_name': genericName,
        'manufacturer': manufacturer,
        'indication': translated[0],
        'side_effect': translated[1],
        'warnings': translated[2],
        'dosage': translated[3],
      };
    } catch (e) {
      return null;
    }
  }

  static String? _getFirst(dynamic field) {
    if (field == null) return null;
    if (field is List && field.isNotEmpty) return field[0].toString();
    if (field is String) return field;
    return null;
  }
}
