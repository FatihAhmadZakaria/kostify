import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/service/midtransService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final String namaKost;
  final int harga;
  final DateTime? selectedDate;
  final int? selectedDuration;
  final int kamarId;

  const CheckoutPage({
    super.key,
    required this.namaKost,
    required this.harga,
    this.selectedDate,
    this.selectedDuration,
    required this.kamarId,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ApiService _apiService = ApiService();
  final MidtransService _midtransService = MidtransService();
  final TextEditingController _promoController = TextEditingController();

  int biayaAdmin = 2000;
  int points = 0;
  int pointsValue = 2000;
  bool usePoints = false;
  int discount = 0;
  int hargaKost = 0;
  String kodePromo = "";
  int userId = 0;

  @override
  void initState() {
    super.initState();
    hargaKost = widget.harga;
    _loadUserData();
    _initMidtrans();
  }

  Future<void> _initMidtrans() async {
    try {
      await _midtransService.initMidtrans(context);
      print("Midtrans SDK berhasil diinisialisasi");
    } catch (e) {
      print("Error inisialisasi Midtrans: $e");
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Cegah error jika widget sudah di dispose
    setState(() {
      userId = prefs.getInt("user_id") ?? 0;
      points = prefs.getInt("credit") ?? 0;
    });
  }

  Future<void> applyPromoCode() async {
    String code = _promoController.text.trim();
    if (code.isEmpty) {
      _showSnackBar("Masukkan kode promo terlebih dahulu!");
      return;
    }

    try {
      var response = await _apiService.checkPromo(code, widget.kamarId);
      if (!mounted) return;
      setState(() {
        if (response['success']) {
          hargaKost = response['harga_promo'];
          discount = widget.harga - hargaKost;
          kodePromo = code;
        } else {
          hargaKost = widget.harga;
          discount = 0;
          kodePromo = "";
        }
      });
      _showSnackBar(response['message']);
    } catch (e) {
      print("Error saat apply promo: $e");
      if (!mounted) return;
      setState(() {
        hargaKost = widget.harga;
        discount = 0;
        kodePromo = "";
      });
      _showSnackBar("Gagal memeriksa kode promo");
    }
  }

  Future<void> submitTransaction() async {
    if (widget.selectedDate == null) {
      _showSnackBar("Pilih tanggal terlebih dahulu sebelum checkout.");
      return;
    }

    int totalHarga = (widget.selectedDuration ?? 1) * hargaKost + biayaAdmin;
    if (usePoints) {
      totalHarga -= (points * pointsValue);
    }
    totalHarga = totalHarga < 0 ? 0 : totalHarga;

    try {
      var response = await _apiService.createTransaction(
        kamarId: widget.kamarId,
        lamaSewa: widget.selectedDuration ?? 1,
        tanggalSewa: DateFormat('yyyy-MM-dd').format(widget.selectedDate!),
        kodePromo: _promoController.text.trim(),
      );

      if (response['success']) {
        String snapToken = response['snap_token'];
        print("Snap Token: $snapToken");
        if (snapToken.isNotEmpty) {
          _midtransService.startPayment(snapToken);
        } else {
          _showSnackBar("Snap token tidak valid, transaksi gagal.");
        }
      } else {
        _showSnackBar(response['message']);
      }
    } catch (e) {
      print("Error transaksi: $e");
      _showSnackBar("Gagal memproses transaksi");
    }
  }

  void toggleUsePoints(bool value) {
    setState(() {
      usePoints = value;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedDate == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Checkout")),
        body: Center(
          child: Text(
            "Pilih tanggal terlebih dahulu sebelum checkout.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    int totalHarga = (widget.selectedDuration ?? 1) * hargaKost;
    int totalPotongan = discount + (usePoints ? points * pointsValue : 0);
    int totalBayar = totalHarga + biayaAdmin - totalPotongan;
    if (totalBayar < 0) totalBayar = 0;

    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.namaKost,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  "Tanggal mulai sewa: ${DateFormat('dd MMM yyyy').format(widget.selectedDate!)}"),
              Text("Durasi: ${widget.selectedDuration ?? 1} bulan"),
              SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("Harga Kost",
                          "Rp. ${NumberFormat('#,###', 'id_ID').format(totalHarga)}"),
                      _buildRow("Biaya Admin",
                          "Rp. ${NumberFormat('#,###', 'id_ID').format(biayaAdmin)}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text("Gunakan Poin",
                                  style: TextStyle(fontSize: 16))),
                          Row(
                            children: [
                              Switch(
                                  value: usePoints, onChanged: toggleUsePoints),
                              Text("$points Poin"),
                            ],
                          ),
                        ],
                      ),
                      if (discount > 0)
                        _buildRow("Diskon Promo", "- Rp. $discount"),
                      Divider(),
                      _buildRow("Total Bayar",
                          "Rp. ${NumberFormat('#,###', 'id_ID').format(totalBayar)}",
                          isBold: true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text("Gunakan Kode Promo"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        hintText: "Masukkan kode promo",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: applyPromoCode,
                    child: Text("Gunakan"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitTransaction,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
                child: Text("Ajukan & Bayar Sekarang"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
