import 'package:hijri/hijri_calendar.dart'; // Add this import for Hijri date

class Jadwal {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String hijri;

  Jadwal({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.hijri
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    // Add Hijri date
    // HijriCalendar.setLocal('id');
    var hijriDate = HijriCalendar.fromDate(DateTime.now());
    String hijriString = '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}';

    return Jadwal(
      tanggal: json['tanggal'],
      imsak: json['imsak'],
      subuh: json['subuh'],
      terbit: json['terbit'],
      dhuha: json['dhuha'],
      dzuhur: json['dzuhur'],
      ashar: json['ashar'],
      maghrib: json['maghrib'],
      isya: json['isya'],
      hijri: hijriString
    );
  }
}