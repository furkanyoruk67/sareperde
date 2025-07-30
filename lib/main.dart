import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/catalog_page.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogPage(),
      ),
    ),
  );
}