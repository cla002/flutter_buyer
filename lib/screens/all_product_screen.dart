import 'package:buyers/models/product_model.dart';
import 'package:buyers/screens/product_details_screen.dart';
import 'package:buyers/widgets/products/all_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:search_page/search_page.dart';

class AllProductListScreen extends StatefulWidget {
  const AllProductListScreen({super.key});

  static const String id = 'product-list-screen';

  @override
  State<AllProductListScreen> createState() => _AllProductListScreenState();
}

class _AllProductListScreenState extends State<AllProductListScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        products = querySnapshot.docs.map((doc) {
          return Product(
            productName: doc['productName'],
            category: doc['category'],
            image: doc['productImage'],
            unit: doc['unit'],
            shopName: doc['seller']['shopName'],
            price: doc['price'],
            comparedPrice: doc['comparedPrice'],
            document: doc,
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green,
            elevation: 0.0,
            title: const Text(
              'All Products',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            floating: true,
            actions: [
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
                                  document: product.document),
                            ),
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
          const SliverList(
            delegate: SliverChildListDelegate.fixed([
              AllProducts(),
            ]),
          ),
        ],
      ),
    );
  }
}
