import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName, category, image, unit, shopName;
  final num price, comparedPrice;
  final DocumentSnapshot document;

  Product({
    required this.productName,
    required this.category,
    required this.image,
    required this.unit,
    required this.shopName,
    required this.price,
    required this.comparedPrice,
    required this.document,
  });
}
