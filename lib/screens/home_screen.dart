import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quran_screen.dart';
import 'jadwal_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _channel = MethodChannel('com.example.mobbb_ads/ad');

  @override
  void initState() {
    super.initState();
    _showAdIfNeeded(); // Menampilkan iklan saat pertama kali aplikasi dibuka
  }

  // Fungsi untuk menampilkan iklan
  Future<void> _showAdIfNeeded() async {
    try {
      await _channel.invokeMethod('showAd');
      print('Iklan berhasil ditampilkan');
    } on PlatformException catch (e) {
      print('Gagal menampilkan iklan: ${e.message}');
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk keluar dari aplikasi
  void _exitApp() {
    Navigator.pop(context); // This will pop the current screen; for full app exit, use system navigator
    SystemNavigator.pop(); // Closes the app completely
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mosque_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur Effect and Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title (Arabic Text)
                Text(
                  'القرآن الكريم',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Arabic',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                // Button List
                _buildMenuButton(
                  'BACA QUR’AN',
                      () async {
                    // await _showAdIfNeeded();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuranScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  'JADWAL SHOLAT',
                      () async {
                    await _showAdIfNeeded();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JadwalScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  'Keluar',
                  _exitApp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build menu buttons
  Widget _buildMenuButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white, width: 2),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}