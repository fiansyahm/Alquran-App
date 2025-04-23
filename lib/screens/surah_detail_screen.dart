import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/surah.dart';
import '../models/ayat.dart';
import '../services/quran_service.dart';
import 'package:audioplayers/audioplayers.dart';


class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  SurahDetailScreen({required this.surah});

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayat>> futureAyat;
  final QuranService quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureAyat = quranService.getAyat(widget.surah.number);
  }

  void _playAudio(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
  }


  String _removeHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  // Calculate Juz number (simplified for demo purposes)
  String _getJuzNumber() {
    return widget.surah.number <= 2 ? 'JUZ 1' : 'JUZ ${widget.surah.number ~/ 4 + 1}';
  }

  // Helper method to map revelation type to Indonesian names
  String _mapRevelationType(String revelationType) {
    if (revelationType.toLowerCase() == 'meccan') {
      return 'Mekkah';
    } else if (revelationType.toLowerCase() == 'medinan') {
      return 'Madinah';
    }
    return revelationType; // Fallback for unexpected values
  }

  String convertToHijriNumber(int number) {
    final List<String> hijriDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) => hijriDigits[int.parse(digit)]).join();
  }

  // Define the darker green color
  static const Color darkGreen = Color(0xFF00695C); // A darker shade of green (teal-like)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getJuzNumber(),
              style: TextStyle(color: Colors.white),
            ),
            Text(
              widget.surah.name,
              style: TextStyle(fontFamily: 'Arabic', fontSize: 20, color: Colors.white),
            ),
            Text(
              '${widget.surah.number}. ${widget.surah.englishName}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: darkGreen, // Darker green for app bar
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            onPressed: () {
              // Add functionality for dropdown if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _mapRevelationType(widget.surah.revelationType),
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  widget.surah.englishName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  '${widget.surah.numberOfAyahs} Ayat',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          // Ayat List
          Expanded(
            child: FutureBuilder<List<Ayat>>(
              future: futureAyat,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: darkGreen, // Use darker green for loading spinner
                      size: 50.0,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: darkGreen), // Use darker green for error text
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data ayat',
                      style: TextStyle(color: darkGreen), // Use darker green for no data text
                    ),
                  );
                } else {
                  List<Ayat> ayatList = snapshot.data!;
                  return ListView.builder(
                    itemCount: ayatList.length,
                    itemBuilder: (context, index) {
                      Ayat ayat = ayatList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ayat Number
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.star_border,
                                  //   color: darkGreen, // Use darker green for star icon
                                  //   size: 40,
                                  // ),
                                  Text(
                                    convertToHijriNumber(ayat.nomor),
                                    style: TextStyle(
                                      color: darkGreen, // Use darker green for number
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            // Ayat Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Arabic Text
                                  Text(
                                    ayat.ar,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Arabic',
                                      color: Colors.black, // Keep Arabic text black for readability
                                    ),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 8),
                                  // Transliterasi
                                  Text(
                                    _removeHtmlTags(ayat.tr),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: darkGreen, // Use darker green for transliterasi
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 8),
                                  // Terjemahan
                                  Text(
                                    ayat.idn,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black, // Keep translation black for readability
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 8),
                                  // Separator
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, size: 10, color: darkGreen), // Use darker green for separator
                                      SizedBox(width: 8),
                                      Icon(Icons.star, size: 10, color: darkGreen),
                                      SizedBox(width: 8),
                                      Icon(Icons.star, size: 10, color: darkGreen),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.play_arrow, color: Colors.green),
                                        onPressed: () => _playAudio(ayat.audioUrl),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.stop, color: Colors.red),
                                        onPressed: _stopAudio,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}