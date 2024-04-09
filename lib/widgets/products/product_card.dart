import 'package:buyers/screens/product_details_screen.dart';
import 'package:buyers/widgets/cart/counter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot document;

  const ProductCard(this.document, {super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String productName = data['productName'];
    String productImage = data['productImage'];
    String unit = data['unit'];
    double price = data['price'];
    double comparedPrice = data['comparedPrice'] ?? 0;

    double offerValue =
        comparedPrice > 0 ? ((comparedPrice - price) / comparedPrice * 100) : 0;
    String offer = offerValue.toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
        height: 140,
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
              context,
              settings: RouteSettings(
                  arguments: ProductDetailScreen(document: document)),
              screen: ProductDetailScreen(document: document),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 5,
                  child: SizedBox(
                    height: 140,
                    width: 130,
                    child: Stack(
                      children: [
                        Container(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                productImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (comparedPrice > 0)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                '$offer% OFF',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 46, 45, 45)),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Container(
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
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            '₱$price',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          if (comparedPrice > 0)
                            Text(
                              '₱$comparedPrice',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 102, 100, 100),
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: CounterForCard(document),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
