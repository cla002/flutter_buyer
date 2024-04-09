// ignore_for_file: prefer_const_constructors

import 'package:buyers/providers/auth_provider.dart';
import 'package:buyers/providers/cart_provider.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/providers/order_provider.dart';
import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/screens/after_login_screen.dart';
import 'package:buyers/screens/home_screen.dart';
import 'package:buyers/screens/main_screen.dart';
import 'package:buyers/screens/map_screen.dart';
import 'package:buyers/screens/my_orders.dart';
import 'package:buyers/screens/product_list_screen.dart';
import 'package:buyers/screens/profile_screen.dart';
import 'package:buyers/screens/splash_screen.dart';
import 'package:buyers/screens/update_after_login.dart';
import 'package:buyers/screens/update_profile_screen.dart';
import 'package:buyers/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MyAuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MyApp(),
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
        primaryColor: Colors.purple.shade900,
      ),
      initialRoute: SplashScreen.id,
      // initialRoute: UpdateProfileAfterLoginScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        SplashScreen.id: (conext) => SplashScreen(),
        MapScreen.id: (context) => MapScreen(),

        MainScreen.id: (context) => MainScreen(),
        // VendorHomeScreen.id: (context) => VendorHomeScreen(document),
        ProductListScreen.id: (context) => ProductListScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        UpdateProfile.id: (context) => UpdateProfile(),
        SetYourLocationScreen.id: (context) => SetYourLocationScreen(),
        MyOrders.id: (context) => MyOrders(),
        UpdateProfileAfterLoginScreen.id: (context) =>
            UpdateProfileAfterLoginScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}
