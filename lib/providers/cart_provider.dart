// ignore_for_file: unnecessary_null_comparison, unnecessary_this

import 'package:buyers/services/cart_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final CartServices _cart = CartServices();
  double subTotal = 0.0;
  int cartQuantity = 0;
  double saving = 0.0;
  double distance = 0.0;
  bool cod = false;
  List cartList = [];

  late QuerySnapshot snapshot;

  Future<double?> getCartTotal() async {
    var cartTotal = 0.0;
    var saving = 0.0;
    List newList = [];
    QuerySnapshot snapshot =
        await _cart.cart.doc(_cart.user!.uid).collection('products').get();
    if (snapshot == null) {
      return null;
    }
    for (var doc in snapshot.docs) {
      if (!newList.contains(doc.data())) {
        newList.add(doc.data());
        this.cartList = newList;
        notifyListeners();
      }
      cartTotal += (doc.data() as Map<String, dynamic>)['total'] ?? 0.0;
      saving = saving +
                  (((doc.data() as Map<String, dynamic>)['comparedPrice'] -
                      (doc.data() as Map<String, dynamic>)['price'])) >
              0
          ? (doc.data() as Map<String, dynamic>)['comparedPrice'] -
              (doc.data() as Map<String, dynamic>)['price']
          : 0;
    }
    this.subTotal = cartTotal;
    this.cartQuantity = snapshot.size;
    this.snapshot = snapshot;
    this.saving = saving;
    notifyListeners();

    return cartTotal;
  }

  getPaymentProvider(index) {
 
    this.cod = true;
  }
}
