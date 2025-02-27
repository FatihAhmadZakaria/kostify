import 'package:flutter/material.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/utility/contentView.dart';

class ListKostPage extends StatefulWidget {
  final String? searchQuery;

  const ListKostPage({super.key, this.searchQuery});

  @override
  State<ListKostPage> createState() => _ListKostPageState();
}

class _ListKostPageState extends State<ListKostPage> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureKamars;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.text = widget.searchQuery ?? "";
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      futureKamars = searchController.text.isEmpty
          ? apiService.fetchKamars()
          : apiService.searchKost(searchController.text);
    });
  }

  void _searchKost() {
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Kost"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama kos/kota',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchKost,
                  ),
                ),
                onSubmitted: (_) => _searchKost(),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<dynamic>>(
                future: futureKamars,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Gagal memuat data kamar"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Center(child: Text("Tidak ada kamar tersedia")),
                    );
                  }
                  return GridListView(kamars: snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
