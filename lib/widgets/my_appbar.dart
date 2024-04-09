// ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison
import 'package:buyers/models/product_model.dart';
import 'package:buyers/screens/product_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:search_page/search_page.dart';

class MyAppBar extends StatefulWidget {
  final DocumentSnapshot? document;

  const MyAppBar({this.document, super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  static List<Product> products = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.green,
      elevation: 0.0,
      title: const Text(
        'E-Tabo',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: SearchPage<Product>(
                      onQueryUpdate: (s) => print(s),
                      items: products,
                      searchLabel: 'Search Products',
                      suggestion: const Center(
                        child:
                            Text('Filter product by name, category or price'),
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
                      builder: (product) => InkWell(
                        onTap: () {
                          print('clicked');
                          PersistentNavBarNavigator
                              .pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(
                                arguments: ProductDetailScreen(
                                    document: product.document)),
                            screen:
                                ProductDetailScreen(document: product.document),
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
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
