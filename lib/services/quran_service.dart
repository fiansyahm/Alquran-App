import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ayat.dart';
import '../models/surah.dart';

class QuranService {
  final String baseUrl = "https://api.alquran.cloud/v1";
  final String baseUrlIndo = "https://quran-api.santrikoding.com/api";
  final String baseUrlIndo2 = "https://equran.id/api/v2";

  Future<List<Surah>> getSurahs() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((surah) => Surah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<Ayat>> getAyat(int surahNumber) async {
    final response = await http.get(Uri.parse('https://equran.id/api/v2/surat/$surahNumber'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> data = jsonData['data']['ayat'];
      return data.map((ayat) => Ayat.fromJson(ayat)).toList();
    } else {
      throw Exception('Gagal memuat ayat');
    }
  }

}