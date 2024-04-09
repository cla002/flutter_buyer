// ignore_for_file: unused_local_variable

import 'package:buyers/globals/styles.dart';
import 'package:buyers/services/cart_services.dart';
import 'package:buyers/widgets/cart/cart_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartList extends StatefulWidget {
  final DocumentSnapshot document;
  const CartList({super.key, required this.document});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final CartServices _cart = CartServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _cart.cart.doc(_cart.user!.uid).collection('products').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: GlobalStyles.screenHeight(context) - 520,
          child: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return CartCard(document: document);
            }).toList(),
          ),
        );
      },
    );
  }
}
