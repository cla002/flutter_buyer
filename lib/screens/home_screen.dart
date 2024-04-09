// ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison, unused_local_variable

import 'package:buyers/providers/auth_provider.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/widgets/carousel.dart';
import 'package:buyers/widgets/category/category_list.dart';
import 'package:buyers/widgets/my_appbar.dart';
import 'package:buyers/widgets/products/all_products.dart';
import 'package:buyers/widgets/vendors/all_vendors.dart';
import 'package:buyers/widgets/vendors/near_vendor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  static const String id = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MyAuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const MyAppBar(),
          ];
        },
        body: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSliderWidget(),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Nearby Vendors',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              VendorNearYourCurrentLocation(),
              Divider(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'All Vendors',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              AllVendors(),
              Divider(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              CategoryList(),
              SizedBox(height: 15),
              Divider(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: SizedBox(
                  height: 480,
                  child: AllProducts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
