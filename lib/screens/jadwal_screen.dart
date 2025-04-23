import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math'; // For Qibla direction calculation
import '../models/city_model.dart';
import '../models/jadwal_model.dart';
import '../services/jadwal_service.dart';

class JadwalScreen extends StatefulWidget {
  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final JadwalService jadwalService = JadwalService();
  Jadwal? jadwal;
  String selectedCity = 'Memuat lokasi...';
  bool isLoading = false;
  DateTime? nextPrayerTime;
  String nextPrayerName = '';
  Duration? timeUntilNextPrayer;
  late tz.Location jakartaTimezone;
  double? qiblaDirection;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    jakartaTimezone = tz.getLocation('Asia/Jakarta');
    _getCurrentLocation();
    _startPrayerCountdown();
  }

  // Get current location and fetch prayer times
  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      String cityName = await getCityName();
      String cityId = await _getCityIdFromCoordinates(cityName);
      Jadwal result = await jadwalService.getJadwal(cityId);
      currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _calculateQiblaDirection(currentPosition!.latitude, currentPosition!.longitude);
      setState(() {
        jadwal = result;
        selectedCity = cityName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        selectedCity = 'Gagal memuat lokasi';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jadwal sholat: $e')),
      );
    }
  }

  // Get city name from coordinates using geocoding and remove prefixes
  Future<String> getCityName() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String? city = placemarks.first.subAdministrativeArea;
        if (city != null && city.isNotEmpty) {
          city = city.replaceAll('Kabupaten ', '').replaceAll('Kota ', '');
          return city;
        }
        return 'Unknown City';
      } else {
        return 'City not found';
      }
    } catch (e) {
      return 'Jakarta'; // Fallback to Jakarta
    }
  }

  // Fetch city ID from MyQuran API
  Future<String> _getCityIdFromCoordinates(String cityName) async {
    try {
      List<City> result = await jadwalService.getCities(cityName);
      if (result.isNotEmpty) {
        setState(() {
          selectedCity = result[0].lokasi;
        });
        return result[0].id;
      } else {
        setState(() {
          selectedCity = 'Jakarta (Fallback)';
        });
        return '1301'; // Fallback to Jakarta
      }
    } catch (e) {
      setState(() {
        selectedCity = 'Jakarta (Fallback)';
      });
      print('Error fetching city ID: $e');
      return '1301'; // Fallback to Jakarta
    }
  }

  // Start countdown for next prayer and update nearest prayer status
  void _startPrayerCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (jadwal != null) {
        tz.TZDateTime now = tz.TZDateTime.now(jakartaTimezone);
        List<Map<String, dynamic>> prayerTimes = [
          {'name': 'Imsak', 'time': jadwal!.imsak},
          {'name': 'Subuh', 'time': jadwal!.subuh},
          {'name': 'Terbit', 'time': jadwal!.terbit},
          {'name': 'Dhuha', 'time': jadwal!.dhuha},
          {'name': 'Dzuhur', 'time': jadwal!.dzuhur},
          {'name': 'Ashar', 'time': jadwal!.ashar},
          {'name': 'Maghrib', 'time': jadwal!.maghrib},
          {'name': 'Isya', 'time': jadwal!.isya},
        ];

        DateFormat timeFormat = DateFormat('HH:mm');
        nextPrayerTime = null;
        nextPrayerName = '';
        tz.TZDateTime? lastPrayerTime;
        String? lastPrayerName;

        for (var prayer in prayerTimes) {
          DateTime prayerTime = timeFormat.parse(prayer['time']!);
          tz.TZDateTime todayPrayerTime = tz.TZDateTime(
            jakartaTimezone,
            now.year,
            now.month,
            now.day,
            prayerTime.hour,
            prayerTime.minute,
          );

          if (todayPrayerTime.isAfter(now)) {
            nextPrayerTime = todayPrayerTime;
            nextPrayerName = prayer['name']!;
            break;
          } else {
            lastPrayerTime = todayPrayerTime;
            lastPrayerName = prayer['name']!;
          }
        }

        if (nextPrayerTime != null) {
          timeUntilNextPrayer = nextPrayerTime!.difference(now);
        }

        setState(() {});
        _startPrayerCountdown();
      }
    });
  }

  // Helper to format time difference
  String _formatTimeDifference(Duration difference) {
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    String prefix = difference.isNegative ? '-' : '+';
    String timeStr = '';
    if (hours.abs() > 0) {
      timeStr += '${hours.abs()} jam ';
    }
    timeStr += '${minutes.abs()} menit';
    return '$prefix$timeStr ${difference.isNegative ? 'yang lalu' : 'akan datang'}';
  }

  // Get nearest prayer status
  String _getNearestPrayerStatus() {
    if (jadwal == null) return '';
    tz.TZDateTime now = tz.TZDateTime.now(jakartaTimezone);
    List<Map<String, String>> prayerTimes = [
      {'name': 'Imsak', 'time': jadwal!.imsak},
      {'name': 'Subuh', 'time': jadwal!.subuh},
      {'name': 'Terbit', 'time': jadwal!.terbit},
      {'name': 'Dhuha', 'time': jadwal!.dhuha},
      {'name': 'Dzuhur', 'time': jadwal!.dzuhur},
      {'name': 'Ashar', 'time': jadwal!.ashar},
      {'name': 'Maghrib', 'time': jadwal!.maghrib},
      {'name': 'Isya', 'time': jadwal!.isya},
    ];

    DateFormat timeFormat = DateFormat('HH:mm');
    tz.TZDateTime? lastPrayerTime;
    String? lastPrayerName;
    tz.TZDateTime? nextPrayerTimeLocal;
    String? nextPrayerNameLocal;

    for (var prayer in prayerTimes) {
      DateTime prayerTime = timeFormat.parse(prayer['time']!);
      tz.TZDateTime todayPrayerTime = tz.TZDateTime(
        jakartaTimezone,
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      if (todayPrayerTime.isAfter(now)) {
        nextPrayerTimeLocal = todayPrayerTime;
        nextPrayerNameLocal = prayer['name']!;
        break;
      } else {
        lastPrayerTime = todayPrayerTime;
        lastPrayerName = prayer['name']!;
      }
    }

    if (nextPrayerTimeLocal != null) {
      return 'Akan masuk Waktu $nextPrayerNameLocal';
    } else if (lastPrayerTime != null) {
      return 'Waktu $lastPrayerName sudah lewat';
    }
    return 'Tidak ada jadwal hari ini';
  }

  // Get time difference from nearest prayer
  String _getNearestPrayerTimeDifference() {
    if (jadwal == null) return '';
    tz.TZDateTime now = tz.TZDateTime.now(jakartaTimezone);
    List<Map<String, String>> prayerTimes = [
      {'name': 'Imsak', 'time': jadwal!.imsak},
      {'name': 'Subuh', 'time': jadwal!.subuh},
      {'name': 'Terbit', 'time': jadwal!.terbit},
      {'name': 'Dhuha', 'time': jadwal!.dhuha},
      {'name': 'Dzuhur', 'time': jadwal!.dzuhur},
      {'name': 'Ashar', 'time': jadwal!.ashar},
      {'name': 'Maghrib', 'time': jadwal!.maghrib},
      {'name': 'Isya', 'time': jadwal!.isya},
    ];

    DateFormat timeFormat = DateFormat('HH:mm');
    tz.TZDateTime? lastPrayerTime;
    tz.TZDateTime? nextPrayerTimeLocal;

    for (var prayer in prayerTimes) {
      DateTime prayerTime = timeFormat.parse(prayer['time']!);
      tz.TZDateTime todayPrayerTime = tz.TZDateTime(
        jakartaTimezone,
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      if (todayPrayerTime.isAfter(now)) {
        nextPrayerTimeLocal = todayPrayerTime;
        break;
      } else {
        lastPrayerTime = todayPrayerTime;
      }
    }

    Duration difference;
    if (nextPrayerTimeLocal != null) {
      difference = nextPrayerTimeLocal.difference(now);
    } else if (lastPrayerTime != null) {
      difference = lastPrayerTime.difference(now);
    } else {
      return '';
    }
    return _formatTimeDifference(difference);
  }

  // Calculate Qibla direction
  void _calculateQiblaDirection(double lat, double lon) {
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    double lat1 = lat * pi / 180;
    double lon1 = lon * pi / 180;
    double lat2 = kaabaLat * pi / 180;
    double lon2 = kaabaLon * pi / 180;

    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x);

    bearing = bearing * 180 / pi;
    bearing = (bearing + 360) % 360;

    setState(() {
      qiblaDirection = bearing;
    });
  }

  static const Color darkGreen = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Sholat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: darkGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: darkGreen))
            : jadwal == null
            ? Center(
          child: Text(
            'Memuat jadwal berdasarkan lokasi...',
            style: TextStyle(fontSize: 16, color: darkGreen),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Hijriah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      jadwal!.hijri, // Replace with dynamic Hijri date if available
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tanggal Masehi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      jadwal!.tanggal,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            if (jadwal != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _getNearestPrayerStatus(),
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getNearestPrayerTimeDifference(),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lokasi: $selectedCity',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    qiblaDirection != null
                        ? 'Arah Kiblat: ${qiblaDirection!.toStringAsFixed(1)}° dari Utara'
                        : 'Menghitung arah Kiblat...',
                    style: TextStyle(fontSize: 14, color: darkGreen),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  PrayerTimeTile('Imsak', jadwal!.imsak),
                  PrayerTimeTile('Subuh', jadwal!.subuh),
                  PrayerTimeTile('Terbit', jadwal!.terbit),
                  PrayerTimeTile('Dhuha', jadwal!.dhuha),
                  PrayerTimeTile('Dzuhur', jadwal!.dzuhur),
                  PrayerTimeTile('Ashar', jadwal!.ashar),
                  PrayerTimeTile('Maghrib', jadwal!.maghrib),
                  PrayerTimeTile('Isya', jadwal!.isya),
                ],
              ),
            ),
            if (nextPrayerTime != null && timeUntilNextPrayer != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Menuju Waktu $nextPrayerName',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '+${timeUntilNextPrayer!.inMinutes} menit lagi',
                      style: TextStyle(fontSize: 16, color: darkGreen),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Simplified PrayerTimeTile without notification functionality
class PrayerTimeTile extends StatelessWidget {
  final String prayerName;
  final String time;

  PrayerTimeTile(this.prayerName, this.time);

  static const Color darkGreen = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      color: Colors.white,
      child: ListTile(
        title: Text(
          prayerName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        subtitle: Text(time, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}