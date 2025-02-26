import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tentang Kami"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kostify",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Kostify adalah platform pencarian dan pemesanan kos yang memudahkan pengguna untuk menemukan tempat tinggal dengan mudah dan cepat. Kami berkomitmen untuk menyediakan layanan terbaik bagi pencari dan pemilik kos dengan fitur yang lengkap dan inovatif.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Visi & Misi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "1. Mempermudah pencari kos dalam menemukan tempat tinggal yang sesuai.\n2. Menyediakan platform yang aman dan terpercaya bagi pemilik kos.\n3. Menghadirkan fitur-fitur inovatif untuk kemudahan transaksi dan komunikasi.\n4. Meningkatkan kualitas hidup penghuni kos dengan layanan yang terbaik.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
