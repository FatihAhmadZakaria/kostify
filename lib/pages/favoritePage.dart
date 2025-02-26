import 'package:flutter/material.dart';
import 'package:kostify/utility/contentView.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorit"),
      ),
      body: ListViewKostFavorit(),
    );
  }
}