import 'package:buyers/globals/styles.dart';
import 'package:buyers/widgets/products/bottom_sheet_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final DocumentSnapshot document;

  const ProductDetailScreen({super.key, required this.document});

  Future<void> saveToFavorite() async {
    CollectionReference favorite =
        FirebaseFirestore.instance.collection('favorites');
    User? user = FirebaseAuth.instance.currentUser;
    await favorite.add({
      'product': document.data(),
      'customerId': user!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String productName = data['productName'] ?? '';
    String productImage = data['productImage'] ?? '';
    String unit = data['unit'] ?? '';
    double price = (data['price'] ?? 0).toDouble();
    double comparedPrice = (data['comparedPrice'] ?? 0).toDouble();
    String productDescription = data['description'] ?? '';
    String seller = (data['seller']?['shopName'] ?? '');
    String category = data['category'] ?? '';
    String collection = data['collection'] ?? '';
    String availableStock = (data['stockQuantity'] ?? 0).toString();

// Ensure that price and comparedPrice are of type double and not null

    double offerValue =
        comparedPrice > 0 ? ((comparedPrice - price) / comparedPrice * 100) : 0;
    String offer = offerValue.toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      bottomSheet: BottomSheetContainer(document),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: GlobalStyles.screenWidth(context),
                    child: Center(
                      child: ClipRRect(
                        child: productImage.isNotEmpty
                            ? Image.network(
                                productImage,
                                fit: BoxFit.cover,
                              )
                            : const Placeholder(), // Provide a placeholder widget when productImage is null or empty
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        productName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 46, 45, 45)),
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade300,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            unit,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 102, 100, 100)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₱$price',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 28),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              if (comparedPrice > 0)
                                Text(
                                  '₱$comparedPrice',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                          if (comparedPrice > 0)
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Text(
                                '$offer% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: const Color.fromARGB(255, 236, 235, 235),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 5),
                              child: Row(
                                children: [
                                  const Text(
                                    'Shop Name: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    seller,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 5),
                              child: Row(
                                children: [
                                  const Text(
                                    'Category: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 5),
                              child: Row(
                                children: [
                                  const Text(
                                    'Collection: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    collection,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'About this Product: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ExpandableText(
                              productDescription,
                              expandText: 'Expand',
                              linkColor: Colors.purple.shade900,
                              collapseText: 'View less',
                              maxLines: 10,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Available Stock: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  availableStock.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
