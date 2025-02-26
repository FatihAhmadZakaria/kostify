import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kostify/pages/checkoutPage.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/utility/contentView.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailKostPage extends StatefulWidget {
  final int idKost;
  final String namaKost;
  final String jenisKost;
  final int harga;

  const DetailKostPage({
    super.key,
    required this.idKost,
    required this.namaKost,
    required this.jenisKost,
    required this.harga,
  });

  @override
  _DetailKostPageState createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  ApiService apiService = ApiService();
  List<String> fotoList = [];
  List<dynamic> reviews = [];
  String luasKamar = "";
  int sisaKamar = 0;
  String keteranganLain = "";
  String keteranganBiaya = "";
  String deskripsi = "";
  String alamat = "";
  bool isLoading = true;
  List<String> fasilitasList = [];
  bool isFavorit = false;
  int? userId;
  String? nomorPemilik;

  DateTime? selectedDate;
  int? selectedDuration;
  final List<int> durationOptions = [1, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    getUserId();
    fetchDetailKost();
  }

  void getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  void _openWhatsApp(String phoneNumber) async {
    // Pastikan nomor dalam format internasional
    if (!phoneNumber.startsWith("62")) {
      phoneNumber = "62${phoneNumber.substring(1)}";
    }

    String message = "Halo, apakah kost ${widget.namaKost} masih tersedia?";
    String url =
        "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}";

    print("Mengirim pesan ke: $url"); // Debugging

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
      );
    }
  }

  void fetchDetailKost() async {
    var response = await apiService.getDetailKost(widget.idKost);
    if (response['success']) {
      setState(() {
        fasilitasList.clear();
        response['data']['fasilitas'].forEach((key, value) {
          if (value == true) {
            String formattedKey = key
                .replaceAll("_", " ")
                .replaceFirst(key[0], key[0].toUpperCase());
            fasilitasList.add(formattedKey);
          }
        });

        fotoList = List<String>.from(response['data']['foto_lain']);
        reviews = response['data']['review'] ?? [];
        luasKamar = response['data']['luas_kamar'];
        sisaKamar = response['data']['sisa_kamar'];
        keteranganLain = response['data']['keterangan_lain'];
        keteranganBiaya = response['data']['keterangan_biaya'];
        deskripsi = response['data']['deskripsi'];
        alamat = response['data']['alamat'];
        nomorPemilik = response['data']['nomor_pemilik'];
        isLoading = false;
        isFavorit = response['data']['status_favorit'] == 1;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  void toggleFavorite() async {
    var response = await apiService.toggleFavorite(widget.idKost);
    if (response['success']) {
      setState(() {
        isFavorit = !isFavorit;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime lastDate = today.add(Duration(days: 60));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _shareKost() {
    Share.share('Cek kost ${widget.namaKost} - Kost ${widget.jenisKost} hanya di https://kostify.nosveratu.com/');
  }

  @override
  Widget build(BuildContext context) {
    int hargaPerBulan = (widget.harga);
    int totalHarga = (selectedDuration ?? 1) * hargaPerBulan;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Kost"),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareKost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : fotoList.isNotEmpty
                    ? CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items: fotoList.map((fotoUrl) {
                          return Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(fotoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Center(child: Text("Tidak ada foto tersedia")),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.namaKost,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    // Ikon WhatsApp
                    IconButton(
                      icon:
                          Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                      onPressed: () {
                        if (nomorPemilik != null && nomorPemilik!.isNotEmpty) {
                          _openWhatsApp(nomorPemilik!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Nomor pemilik tidak tersedia")),
                          );
                        }
                      },
                    ),

                    // Ikon Favorit
                    IconButton(
                      icon: Icon(
                        isFavorit ? Icons.favorite : Icons.favorite_border,
                        color: isFavorit ? Colors.red : Colors.black,
                      ),
                      onPressed: toggleFavorite,
                    ),
                  ],
                ),
              ],
            ),
            Text("${widget.jenisKost} | $luasKamar | Tersisa $sisaKamar kamar"),
            Divider(),
            Text("Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
            GridListFasilitas(fasilitas: fasilitasList),
            Divider(),
            Text("Keterangan Lain",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(keteranganLain),
            Text(keteranganBiaya),
            Text(deskripsi),
            Divider(),
            Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(alamat),
            Divider(),
            Text("Review", style: TextStyle(fontWeight: FontWeight.bold)),
            reviews.isNotEmpty
                ? ReviewList(reviews: reviews)
                : Text("Belum ada review"),
            Divider(),
            Text("Kapan mau sewa Kostnya?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: Text(
                  selectedDate == null
                      ? "Dari tanggal berapa?"
                      : DateFormat('dd MMM yyyy').format(selectedDate!),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white),
              hint: Text("Mau berapa bulan?"),
              value: selectedDuration,
              items: durationOptions.map((int value) {
                return DropdownMenuItem<int>(
                    value: value, child: Text("$value bulan"));
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  selectedDuration = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            Divider(),
            Text(
              "Total: Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sisaKamar <= 0
                    ? null
                    : () {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Harap pilih tanggal mulai sewa terlebih dahulu!"),
                            ),
                          );
                          return;
                        }

                        if (selectedDuration == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Harap pilih durasi sewa terlebih dahulu!"),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              namaKost: widget.namaKost,
                              harga: widget.harga,
                              selectedDate: selectedDate,
                              selectedDuration: selectedDuration,
                              kamarId: widget.idKost,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      sisaKamar <= 0 ? Colors.grey : Colors.lightBlue[600],
                  padding: EdgeInsets.symmetric(
                      vertical: 16), // Tambah padding biar lebih besar
                ),
                child: Text(
                  sisaKamar <= 0 ? "Penuh" : "Selanjutnya",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold), // Tambah ukuran teks
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
