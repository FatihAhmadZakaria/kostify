import 'package:flutter/material.dart';
import 'package:kostify/utility/navbar.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kostify/pages/loginPage.dart';
import 'package:kostify/service/apiService.dart'; // Import API service

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService apiService = ApiService(); // Buat instance ApiService

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.containsKey('id'); // Cek apakah user sudah login

    if (isLoggedIn) {
      // Jika login, lakukan refresh data user sebelum pindah halaman
      await _refreshUserData();
      _navigateToHome(); // Setelah refresh, pindah ke home
    } else {
      _navigateToLogin(); // Jika belum login, langsung ke halaman login
    }
  }

  Future<void> _refreshUserData() async {
    final response = await apiService.getUserById();

    if (!response['success']) {
      print("Gagal memperbarui data user: ${response['message']}");
    } else {
      print("Data user berhasil diperbarui");
    }
  }

  void _navigateToHome() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Nav()), // Menu utama setelah refresh
      );
    });
  }

  void _navigateToLogin() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Ke halaman login
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna background splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/kostify_logo.png", // Path gambar logo
              height: 100, // Sesuaikan ukuran
            ),
            SizedBox(height: 20),
            Text(
              "Kostify", // Nama aplikasi
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue, // Warna teks
              ),
            ),
          ],
        ),
      ),
    );
  }
}
