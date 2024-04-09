import 'package:buyers/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyers/widgets/cart/counter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart'; // Assuming CounterForCard is defined in counter.dart

class FavoriteServices {
  final CollectionReference favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<DocumentSnapshot>> getFavoritesStreamForCurrentUser() {
    return favoritesCollection
        .where('customerId', isEqualTo: currentUserID)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Future<void> removeFromFavorites(String productId) async {
    try {
      // Find the favorite document with the specified productId and delete it
      QuerySnapshot querySnapshot = await favoritesCollection
          .where('customerId', isEqualTo: currentUserID)
          .where('product.productId', isEqualTo: productId)
          .get();
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.delete();
      });
    } catch (e) {
      print('Error removing product from favorites: $e');
    }
  }
}

class FavoriteScreen extends StatefulWidget {
  final DocumentSnapshot? document;

  const FavoriteScreen({Key? key, this.document}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteServices _favoriteServices = FavoriteServices();
  late Stream<List<DocumentSnapshot>> favoritesStream;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    favoritesStream = _favoriteServices.getFavoritesStreamForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: favoritesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No favorite Product found.'),
            );
          } else {
            List<DocumentSnapshot> favorites = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final data =
                          favorites[index].data() as Map<String, dynamic>;
                      final double price = data['product']['price'];
                      final double comparedPrice =
                          data['product']['comparedPrice'];
                      final double saving = comparedPrice - price;
                      final double offerValue = comparedPrice > 0
                          ? ((comparedPrice - price) / comparedPrice * 100)
                          : 0;
                      final String offer = offerValue.toStringAsFixed(0);

                      return InkWell(
                        onTap: () async {
                          final document = favorites[
                              index]; // Get the document corresponding to the tapped item
                          final productId = document['product'][
                              'productId']; // Get the productId from the document
                          if (productId != null) {
                            // Fetch the product details using productId
                            final productDocument = await FirebaseFirestore
                                .instance
                                .collection('products')
                                .doc(productId)
                                .get();
                            if (productDocument.exists) {
                              // Navigate to the product details screen with the fetched productDocument
                              PersistentNavBarNavigator
                                  .pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(
                                  arguments: ProductDetailScreen(
                                      document: productDocument),
                                ),
                                screen: ProductDetailScreen(
                                    document: productDocument),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            } else {
                              print('Product with ID $productId not found.');
                            }
                          } else {
                            print('Product ID is null.');
                          }
                        },
                        child: Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Stack(
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 120,
                                      child: data['product']['productImage'] !=
                                              null
                                          ? Image.network(
                                              data['product']['productImage'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(Icons.error),
                                                );
                                              },
                                            )
                                          : const Placeholder(),
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
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (saving > 0)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            'Saved ₱${saving.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 130.0, top: 5),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['product']['productName'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          data['product']['unit'],
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '₱${price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            if (comparedPrice > 0)
                                              Text(
                                                '₱${comparedPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: Color.fromARGB(
                                                      255, 134, 133, 133),
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0.0,
                                  bottom: 0.0,
                                  child: widget.document != null
                                      ? CounterForCard(widget.document!)
                                      : InkWell(
                                          onTap: () async {
                                            final document = favorites[
                                                index]; // Get the document corresponding to the tapped item
                                            final productId = document[
                                                    'product'][
                                                'productId']; // Get the productId from the document
                                            if (productId != null) {
                                              // Call method to remove product from favorites collection
                                              await _favoriteServices
                                                  .removeFromFavorites(
                                                      productId);
                                              // No need to call _fetchFavorites here
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Product removed from favorites'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            } else {
                                              print('Product ID is null.');
                                            }
                                          },
                                          child: Container(
                                            height: 110,
                                            width: 70,
                                            color: Colors.red,
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ), // or any other widget you'd like to display when document is null
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
