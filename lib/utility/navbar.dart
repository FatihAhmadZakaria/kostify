import 'package:flutter/material.dart';
import 'package:kostify/pages/favoritePage.dart';
import 'package:kostify/pages/historyPage.dart';
import 'package:kostify/pages/homePage.dart';

class Nav extends StatefulWidget {
  final int initialIndex; // Tambahkan parameter untuk menentukan tab awal

  const Nav({super.key, this.initialIndex = 0}); // Default ke Home jika tidak diberikan nilai

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  late int _currentIndex;

  final List<Widget> _pages = [
    HomePage(),
    FavoritePage(),
    HistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set indeks awal sesuai parameter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          _buildNavItem(Icons.home, "Home", 0),
          _buildNavItem(Icons.favorite, "Favorit", 1),
          _buildNavItem(Icons.article, "Riwayat", 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Icon(icon, size: isSelected ? 32 : 24),
      label: label,
    );
  }
}
