import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/screens/product_list_screen.dart';
import 'package:buyers/services/product_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class VendorCategories extends StatefulWidget {
  const VendorCategories({super.key});

  // const VendorCategories({super.key, Key? key});

  @override
  State<VendorCategories> createState() => _VendorCategoriesState();
}

class _VendorCategoriesState extends State<VendorCategories> {
  final ProductServices _services = ProductServices();
  final Set<String> _displayedCategories = {};
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var store = Provider.of<StoreProvider>(context);
    FirebaseFirestore.instance
        .collection('products')
        .where('seller.sellerUid', isEqualTo: store.selectedStoreId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _isLoading = false;
        for (var doc in querySnapshot.docs) {
          _displayedCategories.add(doc['category'] ?? '');
        }
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching categories: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context);
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder(
            future: _services.category.get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something Went Wrong'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          (document.data() as Map<String, dynamic>);
                      String category = data['category'];

                      if (_displayedCategories.contains(category)) {
                        _displayedCategories.remove(category);
                        return InkWell(
                          onTap: () {
                            print(data['category']);
                            storeProvider.selectedCategory(data['category']);
                            PersistentNavBarNavigator
                                .pushNewScreenWithRouteSettings(
                              context,
                              settings: const RouteSettings(
                                  name: ProductListScreen.id),
                              screen: const ProductListScreen(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Card(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Image.network(
                                        data['image'],
                                        height: 50,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    data['category'] ?? '',
                                    style: const TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }).toList(),
                  ),
                );
              } else {
                return const Center(child: Text('No Data Available'));
              }
            },
          );
  }
}
