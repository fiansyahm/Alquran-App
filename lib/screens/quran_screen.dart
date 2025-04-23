import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/surah.dart';
import '../services/quran_service.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> futureSurahs;
  final QuranService quranService = QuranService();

  @override
  void initState() {
    super.initState();
    futureSurahs = quranService.getSurahs();
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
        title: Text('Yuk Ngaji'),
        centerTitle: true,
        backgroundColor: darkGreen, // Darker green for app bar
        actions: [
          // TextButton(
          //   onPressed: () {
          //     // Add functionality for JUZ button if needed
          //   },
          //   child: Text(
          //     'JUZ',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
        ],
      ),
      body: FutureBuilder<List<Surah>>(
        future: futureSurahs,
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
                'Tidak ada data',
                style: TextStyle(color: darkGreen), // Use darker green for no data text
              ),
            );
          } else {
            List<Surah> surahs = snapshot.data!;
            return ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                Surah surah = surahs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Card(
                    elevation: 2,
                    color: Colors.white, // Keep card background white for contrast
                    child: ListTile(
                      leading: CircleAvatar(
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
                              convertToHijriNumber(surah.number),
                              style: TextStyle(
                                color: darkGreen, // Use darker green for number
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.englishName.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black, // Keep text black for readability
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${_mapRevelationType(surah.revelationType).toUpperCase()} | ${surah.numberOfAyahs} AYAT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            surah.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Arabic', // Ensure you have an Arabic font
                              color: Colors.black, // Keep Arabic text black for readability
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.file_download,
                        color: darkGreen, // Use darker green for download icon
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahDetailScreen(surah: surah),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}