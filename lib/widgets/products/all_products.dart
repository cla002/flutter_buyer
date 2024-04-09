// ignore_for_file: unused_local_variable

import 'package:buyers/services/product_services.dart';
import 'package:buyers/widgets/products/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  @override
  Widget build(BuildContext context) {
    ProductServices services = ProductServices();

    return FutureBuilder<QuerySnapshot>(
      future: services.products.where('published', isEqualTo: true).get(),
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
            child: const Center(child: Text('No Product Available')),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ProductCard(document);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
