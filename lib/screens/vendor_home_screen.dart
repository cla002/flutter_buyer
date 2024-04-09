// ignore_for_file: unused_field, deprecated_member_use

import 'package:buyers/globals/styles.dart';
import 'package:buyers/models/product_model.dart';
import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/screens/product_details_screen.dart';
import 'package:buyers/screens/report_seller.dart';
import 'package:buyers/widgets/products/best_selling.dart';
import 'package:buyers/widgets/products/featured_products.dart';
import 'package:buyers/widgets/products/recently_added.dart';
import 'package:buyers/widgets/vendors/vendor_banner_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorHomeScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const VendorHomeScreen(this.document, {super.key});

  static const String id = 'vendor-home-screen';

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  static List<Product> products = [];
  String? shopName;
  DocumentSnapshot? _documentSnapshot;
  late double latitude = 0.0;
  late double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.document['uid'])
        .get()
        .then((DocumentSnapshot vendorDoc) {
      GeoPoint location = vendorDoc['location'];
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });
    });

    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          _documentSnapshot = doc;
          products.add(Product(
              productName: doc['productName'],
              category: doc['category'],
              image: doc['productImage'],
              unit: doc['unit'],
              shopName: doc['seller']['shopName'],
              price: doc['price'],
              comparedPrice: doc['comparedPrice'],
              document: doc));
        });
      }
    });
  }

  @override
  void dispose() {
    products.clear();
    super.dispose();
  }

  void _launchMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);

    // Calculate distance using latitude and longitude
    double distance = Geolocator.distanceBetween(
      storeData.userLatitude,
      storeData.userLongitude,
      latitude,
      longitude,
    );
    double distanceInKm = distance / 1000;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              storeData.selectedStoreName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  shopName = storeData.selectedStoreName;
                });
                showSearch(
                  context: context,
                  delegate: SearchPage<Product>(
                    onQueryUpdate: (s) => print(s),
                    items: products,
                    searchLabel: 'Search Products',
                    suggestion: const Center(
                      child: Text('Filter product by name, category or price'),
                    ),
                    failure: const Center(
                      child: Text('No product found'),
                    ),
                    filter: (product) => [
                      product.productName,
                      product.category,
                      product.unit,
                      product.shopName,
                      product.price.toString(),
                    ],
                    builder: (product) => shopName != product.shopName
                        ? Container()
                        : InkWell(
                            onTap: () {
                              PersistentNavBarNavigator
                                  .pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(
                                    arguments: ProductDetailScreen(
                                        document: product.document)),
                                screen: ProductDetailScreen(
                                    document: product.document),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: ListTile(
                              leading: Image.network(
                                product.image,
                                height: 30,
                              ),
                              title: Text(product.productName),
                              subtitle: Text(product.category),
                              trailing: Text("₱${product.price.toString()}"),
                            ),
                          ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: SizedBox(
                  height: 280.0,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: GlobalStyles.screenWidth(context),
                        child: Image.network(
                          storeData.selectedStoreImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            color: Colors.green.withOpacity(0.9),
                            width: double.infinity,
                            height: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [],
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star_half,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star_outline,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '(3.5)',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            storeData.selectedStoreDialog,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Divider(),
                                        Row(
                                          children: [
                                            const Text(
                                              'Address:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Text(
                                                storeData.selectedStoreAddress,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          'Contacts:',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0),
                                            child: Column(children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.email,
                                                      color: Colors.white),
                                                  const Text(
                                                    ' : ',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      storeData
                                                          .selectedStoreEmail,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone,
                                                      color: Colors.white),
                                                  const Text(
                                                    ' : ',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "+63${storeData.selectedStorePhone}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      color: Colors.white),
                                                  const Text(
                                                    ' Distance to Seller:',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    '${distanceInKm.toStringAsFixed(2)} km',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _launchMap(
                                                          latitude, longitude);
                                                    },
                                                    child: const Text(
                                                        'View on Map'),
                                                  ),
                                                ],
                                              ),
                                            ]))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportSeller(
                                  sellerId: widget.document['uid'],
                                  shopName: widget.document['shopName'],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.report),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 60,
                width: GlobalStyles.screenWidth(context),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('lib/images/background.jpg'),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'E-Tabo',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const VendorBanner(),
              const SizedBox(
                height: 15,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Products Section',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const BestSellingProducts(),
              const RecentlyAddedProducts(),
              const FeaturedProducts(),
            ],
          ),
        ),
      ),
    );
  }
}
