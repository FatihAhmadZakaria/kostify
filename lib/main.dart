import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kostify/utility/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Aplikasi Dimulai");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cardTheme: CardTheme(
          color: Colors.white, // Ubah warna default Card di seluruh aplikasi
          shadowColor: Colors.grey.withOpacity(0.5), // Bayangan Card
          elevation: 4, // Tinggi bayangan
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Border radius Card
          ),
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        primarySwatch: Colors.lightBlue, // Warna utama
        primaryColor: Colors.lightBlue[700], // Warna utama lebih pekat
        scaffoldBackgroundColor:
            Colors.white, // Warna latar belakang aplikasi
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[700], // Warna AppBar
          foregroundColor: Colors.white, // Warna teks AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[600], // Warna tombol utama
            foregroundColor: Colors.white, // Warna teks tombol
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
