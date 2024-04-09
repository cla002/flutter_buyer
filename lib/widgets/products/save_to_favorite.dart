import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveToFavorites extends StatelessWidget {
  const SaveToFavorites(this.document, {Key? key}) : super(key: key);

  final DocumentSnapshot document;

  Future<void> saveToFavorite() async {
    try {
      CollectionReference favorite =
          FirebaseFirestore.instance.collection('favorites');
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the product already exists for the current user
      QuerySnapshot querySnapshot = await favorite
          .where('customerId', isEqualTo: user!.uid)
          .where('product.productId', isEqualTo: document['productId'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Product does not exist for the user, add it to favorites
        await favorite.add({
          'product': document.data(),
          'customerId': user.uid,
        });
        EasyLoading.showSuccess('Saved Successfully');
      } else {
        // Product already exists for the user, show a message
        EasyLoading.showError('Product already saved to favorites');
      }
    } catch (e) {
      print('Error saving product to favorites: $e');
      EasyLoading.showError('Failed to save to favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        EasyLoading.show(status: 'Saving...');
        saveToFavorite();
      },
      child: Container(
        height: 50,
        color: Colors.purple.shade900,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Save to Favorite',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
