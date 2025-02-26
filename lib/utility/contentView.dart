import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kostify/pages/detailKostPage.dart';
import 'package:kostify/pages/listKostPage.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/utility/constant.dart';

class HorizontalCityListView extends StatelessWidget {
  final List<Map<String, String>> cities = [
    {
      "name": "Jakarta",
      "image": "https://kostify.nosveratu.com/assets/images/city/jakarta.png"
    },
    {
      "name": "Bandung",
      "image": "https://kostify.nosveratu.com/assets/images/city/bandung.png"
    },
    {
      "name": "Surabaya",
      "image": "https://kostify.nosveratu.com/assets/images/city/surabaya.png"
    },
    {
      "name": "Yogyakarta",
      "image": "https://kostify.nosveratu.com/assets/images/city/jogja.png"
    },
    {
      "name": "Malang",
      "image": "https://kostify.nosveratu.com/assets/images/city/malang.png"
    },
    {
      "name": "Medan",
      "image": "https://kostify.nosveratu.com/assets/images/city/medan.png"
    },
    {
      "name": "Semarang",
      "image": "https://kostify.nosveratu.com/assets/images/city/semarang.png"
    },
    {
      "name": "Lihat Semua",
      "image":
          "https://media.istockphoto.com/id/1027892522/photo/abstract-old-brick-wall-in-the-dark-with-spotlight-warm-light-tone.jpg?s=612x612&w=0&k=20&c=IXJKHIWXWpaFWA8q8lg62tcE7recPjyqeH4PSal0mfY="
    },
  ];

  HorizontalCityListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          String cityName = cities[index]["name"]!;
          String imageUrl = cities[index]["image"]!;

          return GestureDetector(
            onTap: () {
              // Navigasi ke ListKostPage dengan searchQuery sesuai nama kota
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListKostPage(searchQuery: cityName),
                ),
              );
            },
            child: Container(
              width: 200,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GridListView extends StatelessWidget {
  final List<dynamic> kamars;

  const GridListView({super.key, required this.kamars});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: kamars.length,
      itemBuilder: (context, index) {
        final kamar = kamars[index];

        return GestureDetector(
          // Tambahkan GestureDetector agar bisa diklik
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailKostPage(
                  idKost: kamar['id'],
                  namaKost: kamar['nama'],
                  jenisKost: kamar['jenis_kamar'],
                  harga: kamar['harga'],
                ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Kamar
                Flexible(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      kamar['gambar'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                // Informasi Kamar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kamar['nama'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Rp ${NumberFormat('#,###', 'id_ID').format(kamar['harga'])}",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        kamar['kota'],
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            kamar['jenis_kamar'],
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListViewKostFavorit extends StatefulWidget {
  const ListViewKostFavorit({super.key});

  @override
  _ListViewKostFavoritState createState() => _ListViewKostFavoritState();
}

class _ListViewKostFavoritState extends State<ListViewKostFavorit> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureFavorit;

  @override
  void initState() {
    super.initState();
    futureFavorit = apiService.fetchFavorit();
  }

  // ✅ Fungsi untuk refresh halaman dan update SharedPreferences
  Future<void> _refreshFavorit() async {
    await apiService.getUserById(); // Perbarui data user di SharedPreferences
    setState(() {
      futureFavorit = apiService.fetchFavorit(); // Refresh data favorit
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFavorit, // ✅ Tambahkan fitur refresh
      child: FutureBuilder<List<dynamic>>(
        future: futureFavorit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan saat memuat data."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Belum ada kost favorit."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var kost = snapshot.data![index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailKostPage(
                        idKost: kost['id'],
                        namaKost: kost['nama'],
                        jenisKost: kost['jenis_kamar'],
                        harga: kost['harga'],
                      ),
                    ),
                  ).then((_) => _refreshFavorit()); // ✅ Refresh setelah kembali
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar kos
                      ClipRRect(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(8)),
                        child: Container(
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: kost['gambar'] != null
                                ? DecorationImage(
                                    image: NetworkImage(kost['gambar']),
                                    fit: BoxFit.cover,
                                    onError: (error, stackTrace) =>
                                        const DecorationImage(
                                      image: AssetImage('assets/no_image.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : DecorationImage(
                                    image: AssetImage('assets/no_image.png'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      // Konten teks
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kost['nama'] ?? "Nama Kos",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    kost['kota'] ?? "Kota",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Text(
                                "Rp ${kost['harga'] != null ? NumberFormat('#,###', 'id_ID').format(kost['harga']) : "Harga"} / bulan",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    kost['jenis_kamar'] ?? "Campur",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ListHistory extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onPay; // Fungsi pembayaran
  final Function(int) onDelete; // Fungsi hapus transaksi

  const ListHistory({
    super.key,
    required this.transactions,
    required this.onPay,
    required this.onDelete,
  });

  void _showReviewDialog(BuildContext context, int transaksiId) {
    int selectedRating = 5;
    TextEditingController ulasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Tulis Ulasan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Ulasan hanya bisa dikirim sekali dan tidak bisa diubah."),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: ulasanController,
                    decoration: InputDecoration(labelText: "Masukkan ulasan"),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Batal"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text("Kirim"),
                  onPressed: () async {
                    ApiService apiService = ApiService();
                    final response = await apiService.submitReview(
                      transaksiId: transaksiId,
                      rating: selectedRating,
                      ulasan: ulasanController.text,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaksi = transactions[index];
        bool isPaid = transaksi["status_pembayaran"] == "Success";
        bool hasReviewed = transaksi["status_review"] == 1;
        bool isPending = transaksi["status_pembayaran"] == "Pending";

        return Card(
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey, width: 1),
          ),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nama Kost: ${transaksi['nama_kost']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "Total Transaksi: Rp ${transaksi['total_transaksi'] != null ? NumberFormat('#,###', 'id_ID').format(transaksi['total_transaksi']) : "0"}"),
                          Text("Lama Sewa: ${transaksi['lama_sewa']} bulan"),
                          Text(
                              "Status Pembayaran: ${transaksi['status_pembayaran']}"),
                          Text(
                              "Status Transaksi: ${transaksi['status_transaksi']}"),
                        ],
                      ),
                    ),

                    // Tombol Review jika transaksi sukses tetapi belum direview
                    if (isPaid && !hasReviewed)
                      IconButton(
                        icon: Icon(Icons.rate_review, color: Colors.blue),
                        onPressed: () {
                          _showReviewDialog(context, transaksi["id_transaksi"]);
                        },
                      ),

                    // Jika transaksi masih Pending, tampilkan tombol Bayar dan Hapus
                    if (isPending)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.payment, color: Colors.green),
                            onPressed: () => onPay(transaksi["snap_token"]),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                onDelete(transaksi["id_transaksi"]),
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
}

class GridListFasilitas extends StatelessWidget {
  final List<String> fasilitas;

  const GridListFasilitas({super.key, required this.fasilitas});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 5,
      children: fasilitas.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item,
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}

class ReviewList extends StatelessWidget {
  final List<dynamic> reviews;

  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews.map((review) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(review['foto_profile'] ?? defaultProfile),
            onBackgroundImageError: (_, __) =>
                const NetworkImage(defaultProfile),
          ),
          title: Text(review['nama_user'],
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review['ulasan']),
              Row(
                children: List.generate(
                  int.tryParse(review['rating'].toString()) ??
                      0, // Konversi aman
                  (index) => Icon(Icons.star, color: Colors.orange, size: 16),
                ),
              ),
              Text(review['tanggal'],
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
