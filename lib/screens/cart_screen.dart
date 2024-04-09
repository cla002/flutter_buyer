// ignore_for_file: sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable

import 'package:buyers/providers/cart_provider.dart';
import 'package:buyers/screens/main_screen.dart';
import 'package:buyers/services/store_services.dart';
import 'package:buyers/widgets/cart/bottom_sheet_cart.dart';
import 'package:buyers/widgets/cart/cart_list.dart';
import 'package:buyers/widgets/cart/shop_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final DocumentSnapshot document;
  const CartScreen({required this.document});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<DocumentSnapshot?> _shopDetailsFuture;
  late DocumentSnapshot doc;

  @override
  void initState() {
    super.initState();
    _shopDetailsFuture = _fetchShopDetails();
    doc = widget.document;
  }

  Future<DocumentSnapshot?> _fetchShopDetails() async {
    try {
      var sellerUid =
          (widget.document.data() as Map<String, dynamic>)['sellerUid'];
      if (sellerUid != null) {
        return await StoreServices().getShopDetails(sellerUid);
      } else {
        throw Exception('Seller UID is null');
      }
    } catch (error) {
      print('Error fetching shop details: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: doc.data() == null
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Your Basket is Empty...'),
                TextButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                        context,
                        settings: const RouteSettings(arguments: MainScreen.id),
                        screen: const MainScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.w500),
                    ))
              ],
            ))
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        elevation: 0.0,
                        title: FutureBuilder<DocumentSnapshot?>(
                          future: _shopDetailsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              DocumentSnapshot? doc = snapshot.data;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc != null &&
                                                doc.exists &&
                                                doc.data() != null
                                            ? ((doc.data() as Map<String,
                                                    dynamic>)['shopName'] ??
                                                'Unknown Shop')
                                            : 'Unknown Shop',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer<CartProvider>(
                                        builder: (context, cartProvider, _) {
                                          String itemsText =
                                              cartProvider.cartQuantity == 1
                                                  ? 'item'
                                                  : 'items';
                                          return Text(
                                            '${cartProvider.cartQuantity} $itemsText',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          );
                                        },
                                      ),
                                      Consumer<CartProvider>(
                                        builder: (context, cartProvider, _) {
                                          return Text(
                                            'Sub Total :   ₱${cartProvider.subTotal}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot?>(
                        future: _shopDetailsFuture,
                        builder: (context, snapshot) {
                          print('Snapshot: $snapshot');
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SliverToBoxAdapter(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Text('Error: ${snapshot.error}'),
                              ),
                            );
                          } else {
                            DocumentSnapshot? doc = snapshot.data;
                            print('Document: $doc');
                            if (doc != null) {
                              return ShopDetailsWidget(doc);
                            } else {
                              return const SliverToBoxAdapter(
                                child: Center(
                                  child: Text('No Shop details available'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                                'Note: You can only add products from one store at a time.'),
                            CartList(document: widget.document),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // if (doc.data() != null)
                //   BottomSheetWidget(
                //       (doc.data() as Map<String, dynamic>)['uid'] ?? ''),
                if (doc.data() != null) BottomSheetWidget(doc),
              ],
            ),
    );
  }
}
