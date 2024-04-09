// ignore_for_file: prefer_final_fields, unused_field

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/cart_provider.dart';
import 'package:buyers/screens/cart_screen.dart';
import 'package:buyers/services/cart_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
  const CartNotification({super.key});

  @override
  State<CartNotification> createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  CartServices _cart = CartServices();
  DocumentSnapshot? document;
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    cartProvider.getCartTotal();

    String itemsText = cartProvider.cartQuantity == 1 ? 'item' : 'items';
    _cart.getShopName().then((value) {
      setState(() {
        document = value;
      });
    });

    return Container(
      height: 45,
      width: GlobalStyles.screenWidth(context),
      color: Colors.purple.shade900,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cartProvider.cartQuantity} $itemsText',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Seller : ',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      Text(
                        document != null && document!.exists
                            ? (document!.data()
                                    as Map<String, dynamic>)['shopName'] ??
                                'Unknown Shop'
                            : 'Loading...',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (document != null) {
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(
                        arguments: CartScreen(document: document!)),
                    screen: CartScreen(document: document!),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                } else {
                  // Show a dialog or a snackbar to inform the user that the document is not available
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'The seller information is not available. Please try again later.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                child: const Row(
                  children: [
                    Text(
                      'View Basket',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.shopping_basket,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
