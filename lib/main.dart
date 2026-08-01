import 'package:e_commerce/provider/auth_provider.dart';
import 'package:e_commerce/provider/categories_provider.dart';
import 'package:e_commerce/provider/navigation_provider.dart';
import 'package:e_commerce/provider/order_history_provider.dart';
import 'package:e_commerce/provider/products_provider.dart';
import 'package:e_commerce/provider/profile_provider.dart';
import 'package:e_commerce/screens/cart_screen.dart';
import 'package:e_commerce/screens/edit_profile_screen.dart';
import 'package:e_commerce/screens/home_screen.dart';
import 'package:e_commerce/screens/login_screen.dart';
import 'package:e_commerce/screens/main_shell.dart';
import 'package:e_commerce/screens/signup_screen.dart';
import 'package:e_commerce/screens/splash.dart';
import 'package:e_commerce/screens/wishlist_screen.dart';
import 'package:e_commerce/services/auth_service.dart';
import 'package:e_commerce/services/categories_service.dart';
import 'package:e_commerce/services/products_service.dart';
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
          Provider<AuthService>(create: (_)=> AuthService()),
          Provider<CategoriesService>(create: (_)=> CategoriesService()),
          Provider<ProductsService>(create: (_)=> ProductsService()),
          ChangeNotifierProvider(create: (context)=> AuthProvider(context.read<AuthService>())),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (context)=> ProfileProvider()),
          ChangeNotifierProvider(create: (context) => ProductsProvider(context.read<ProductsService>())),
          ChangeNotifierProvider(create: (context) => CategoriesProvider(context.read<CategoriesService>())),
          ChangeNotifierProvider(create: (context) => OrderHistoryFilterProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const MainShell(),
          },
        ));
  }
}