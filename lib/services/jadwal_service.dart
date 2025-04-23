import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city_model.dart';
import '../models/jadwal_model.dart';

class JadwalService {
  final String baseUrl = "https://api.myquran.com/v2/sholat";

  // Mengambil daftar kota/kabupaten
  Future<List<City>> getCities(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/kota/cari/$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((city) => City.fromJson(city)).toList();
    } else {
      throw Exception('Gagal memuat data kota');
    }
  }

  // Mengambil jadwal sholat berdasarkan ID kota
  Future<Jadwal> getJadwal(String cityId) async {
    final now = DateTime.now();
    final formattedDate = "${now.year}/${now.month}/${now.day}";
    final response = await http.get(Uri.parse('$baseUrl/jadwal/$cityId/$formattedDate'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body)['data']['jadwal'];
      return Jadwal.fromJson(data);
    } else {
      throw Exception('Gagal memuat jadwal sholat');
    }
  }
}