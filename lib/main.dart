import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/catalog_page.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogPage(),
      ),
    ),
  );
}