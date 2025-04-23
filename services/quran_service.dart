import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class QuranService {
  final String baseUrl = "https://api.alquran.cloud/v1";

  Future<List<Surah>> getSurahs() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((surah) => Surah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }
}