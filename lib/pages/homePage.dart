import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kostify/pages/aboutUsPage.dart';
import 'package:kostify/pages/editProfilePage.dart';
import 'package:kostify/pages/listKostPage.dart';
import 'package:kostify/pages/loginPage.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/utility/contentView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureKamars;

  String profileImage =
      "https://c4.wallpaperflare.com/wallpaper/950/884/848/anime-girls-icons-profile-hd-wallpaper-thumb.jpg";
  String username = "Username";
  String email = "user@example.com";
  String noWa = "081234567890";
  String credit = "0";

  @override
  void initState() {
    super.initState();
    futureKamars = apiService.fetchKamars();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Loading User Data from SharedPreferences:");
    print("Name: ${prefs.getString('name')}");
    print("Email: ${prefs.getString('email')}");
    print("No WA: ${prefs.getString('no_wa')}");
    print("Credit: ${prefs.getString('credit')}");

    setState(() {
      profileImage = prefs.getString('foto') ?? profileImage;
      username = prefs.getString('name') ?? username;
      email = prefs.getString('email') ?? email;
      noWa = prefs.getString('no_wa') ?? noWa;
      credit = prefs.getString('credit') ?? credit;
    });
  }

  Future<void> _refreshData() async {
    await apiService.getUserById(); // Ambil data terbaru dari API
    await _loadUserData(); // Perbarui nilai dari SharedPreferences
    setState(() {}); // Paksa UI untuk di-refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue[700]),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  Text(
                    username,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          noWa.length > 12 ? noWa.substring(0, 12) : noWa,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(width: 1, height: 12, color: Colors.white),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          email.length > 12 ? email.substring(0, 12) : email,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Tentang Kami"),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()));
              },
            ),
            ListTile(
              title: Text("Edit Profil"),
              leading: Icon(Icons.edit),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()));
              },
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () async {
                await logoutUser(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/img/bannerHome1.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: double.infinity,
                    ),
                    Container(color: Colors.black.withOpacity(0.2)),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Mau Cari Kos?",
                                style: TextStyle(
                                    fontSize: 44, color: Colors.white)),
                            Text("Lebih mudah pesan dan sewa di Kostify.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan nama kos/kota',
                                          hintStyle: TextStyle(fontSize: 12),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListKostPage(
                                                          searchQuery: value)),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (_searchController.text.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ListKostPage(
                                                        searchQuery:
                                                            _searchController
                                                                .text)),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.search,
                                          color: Colors.blue),
                                      tooltip: "Cari",
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Rekomendasi kota",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 5),
                  HorizontalCityListView(),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Rekomendasi kost",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FutureBuilder<List<dynamic>>(
                      future: futureKamars,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Gagal memuat data kamar"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text("Tidak ada kamar tersedia"));
                        }

                        return GridListView(kamars: snapshot.data!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> logoutUser(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
}
