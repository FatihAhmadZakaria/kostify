import 'package:flutter/material.dart';
import 'package:kostify/utility/navbar.dart';

class LandingTransaction extends StatelessWidget {
  const LandingTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran hijau dengan ikon centang
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green, // Warna hijau
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check, // Ikon centang
                color: Colors.white, // Warna ikon putih
                size: 50,
              ),
            ),
            SizedBox(height: 20),
            // Teks pesan transaksi
            Text(
              "Yeyy.. Transaksi kamu berhasil dibuat.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Silahkan tunggu pemilik kost melakukan konfirmasi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              "Jika belum selesai, cek halaman riwayat transaksi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Colors.lightBlue,
        child: TextButton(
          onPressed: () {
            // Navigasi ke halaman Home di Nav
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Nav(initialIndex: 0)),
            );
          },
          child: Text("Kembali ke Home", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
