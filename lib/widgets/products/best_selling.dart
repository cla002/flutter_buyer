// ignore_for_file: unused_local_variable

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/services/product_services.dart';
import 'package:buyers/widgets/products/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BestSellingProducts extends StatelessWidget {
  const BestSellingProducts({super.key});

  @override
  Widget build(BuildContext context) {
    ProductServices services = ProductServices();
    var store = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: services.products
          .where('published', isEqualTo: true)
          .where('collection', isEqualTo: 'Best Selling')
          .where('seller.sellerUid', isEqualTo: store.selectedStoreId)
          .orderBy('productName')
          .limitToLast(10)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return Container(
            child: const Center(
                child: Text('No Best Selling Products For this Store')),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 40,
                  width: GlobalStyles.screenWidth(context),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Best Selling',
                      style: TextStyle(
                        fontSize: 14,
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
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ProductCard(document);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
