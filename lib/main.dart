import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Providers/add_provider.dart';
import 'package:vezigo/Providers/fav_provider.dart';
import 'package:vezigo/Providers/item_provider.dart';
import 'package:vezigo/Providers/profiles_provider.dart';

import 'package:vezigo/Providers/signup_provider.dart';
import 'package:vezigo/Screens/splashscreen.dart';
import 'package:vezigo/Screens/cart_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => SignupProvider()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
