import 'package:e_commerce/provider/auth_service_provider.dart';
import 'package:e_commerce/provider/categories.provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/provider/wishlist_provider.dart';
import 'package:e_commerce/screens/home_screen.dart';
import 'package:e_commerce/screens/login_screen.dart';
import 'package:e_commerce/screens/product_screen.dart';
import 'package:e_commerce/screens/splash.dart';
import 'package:e_commerce/screens/wishlist_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=> AuthService()),
          ChangeNotifierProvider(create: (context) => ProductsProvider()),
          ChangeNotifierProvider(create: (context) => CategoriesProvider()),
          ChangeNotifierProvider(create: (context)=>WishlistProvider())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/wishlist': (context)=> const WishlistScreen()
          },
        ));
  }
}