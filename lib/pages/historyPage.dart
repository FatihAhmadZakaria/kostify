import 'package:flutter/material.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/service/midtransService.dart';
import 'package:kostify/utility/contentView.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService apiService = ApiService();
  final MidtransService _midtransService = MidtransService();
  late Future<Map<String, dynamic>> futureHistory;

  @override
  void initState() {
    super.initState();
    futureHistory = apiService.fetchHistory();
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

  Future<void> _refreshHistory() async {
    // Perbarui data user di SharedPreferences
    await apiService.getUserById();

    // Perbarui data transaksi
    setState(() {
      futureHistory = apiService.fetchHistory();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ✅ Fungsi untuk memproses pembayaran
  void _processPayment(String snapToken) {
    print("Memulai pembayaran dengan snapToken: $snapToken");
    if (snapToken.isNotEmpty) {
      _midtransService.startPayment(snapToken);
    } else {
      _showSnackBar("Snap token tidak valid, transaksi gagal.");
    }
  }

  // ✅ Fungsi untuk menghapus transaksi
  void _confirmDeleteTransaction(int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus Transaksi"),
          content: Text("Apakah Anda yakin ingin menghapus transaksi ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                final response =
                    await apiService.deleteTransaction(transactionId);
                bool success = response['success'];

                if (success) {
                  setState(() {
                    futureHistory = apiService.fetchHistory(); // 🔄 Reload data
                  });
                  _showSnackBar(response['message']);
                } else {
                  _showSnackBar(response['message']);
                }

                Navigator.pop(context); // Tutup dialog setelah proses selesai
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Transaksi")),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                !snapshot.data!['success']) {
              return Center(
                  child:
                      Text(snapshot.data?['message'] ?? "Terjadi kesalahan"));
            }

            List<Map<String, dynamic>> transactions =
                List<Map<String, dynamic>>.from(snapshot.data!['data'] ?? []);

            if (transactions.isEmpty) {
              return Center(child: Text("Belum ada transaksi yang dilakukan"));
            }

            return ListHistory(
              transactions: transactions,
              onPay: _processPayment, // ✅ Kirim fungsi pembayaran
              onDelete:
                  _confirmDeleteTransaction, // ✅ Kirim fungsi hapus transaksi
            );
          },
        ),
      ),
    );
  }
}
