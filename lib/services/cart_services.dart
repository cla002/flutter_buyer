// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartServices {
  CollectionReference cart = FirebaseFirestore.instance.collection('cart');

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> addToCart(document) async {
    cart.doc(user!.uid).set({
      'user': user!.uid,
      'sellerUid': document.data()['seller']['sellerUid'],
      'shopName': document.data()['seller']['shopName'],
    });
    await cart.doc(user!.uid).collection('products').add({
      'productId': document.data()['productId'],
      'productName': document.data()['productName'],
      'productImage': document.data()['productImage'],
      'unit': document.data()['unit'],
      'price': document.data()['price'],
      'comparedPrice': document.data()['comparedPrice'],
      'quantity': 1,
      'total': document.data()['price'],
    });
  }

  Future<void> updateCartQuantity(docId, quantity, total) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .doc(docId);

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            throw Exception("[Product] does not exist in Cart!");
          }

          var price = (snapshot.data() as Map<String, dynamic>)['price'];
          var newTotal = price * quantity;

          transaction.update(
            documentReference,
            {
              'quantity': quantity,
              'total': newTotal,
            },
          );

          // Return the new count
          return quantity;
        })
        .then((value) => print("Cart Updated"))
        .catchError((error) => print("Failed to update Cart: $error"));
  }

  Future<void> removeFromCart(docId) async {
    cart.doc(user!.uid).collection('products').doc(docId).delete();
  }

  Future<void> checkData() async {
    final snapshot = await cart.doc(user!.uid).delete();
  }

  Future<void> deleteCart() async {
    final snapshot =
        await cart.doc(user!.uid).collection('products').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<String?> checkSeller() async {
    final snapshot = await cart.doc(user!.uid).get();
    final data = snapshot.data() as Map<String, dynamic>?;
    return data != null ? data['shopName'] as String? : null;
  }

  Future<DocumentSnapshot> getShopName() async {
    DocumentSnapshot doc = await cart.doc(user!.uid).get();
    return doc;
  }
}
