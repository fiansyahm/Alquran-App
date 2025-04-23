class Ayat {
  final int id;
  final int surah;
  final int nomor;
  final String ar; // Teks Arab
  final String tr; // Teks transliterasi
  final String idn; // Terjemahan dalam bahasa Indonesia
  final String audioUrl; //audio

  Ayat({
    required this.id,
    required this.surah,
    required this.nomor,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.audioUrl,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json['nomorAyat'],
      surah: json['nomorAyat'],

      nomor: json['nomorAyat'],
      ar: json['teksArab'],
      tr: json['teksLatin'],
      idn: json['teksIndonesia'],
      audioUrl: json['audio']['05'], // Mengambil audio dari Mishary Rashid Al-Afasy
    );
  }
}