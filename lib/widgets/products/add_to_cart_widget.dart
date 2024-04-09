import 'package:buyers/services/cart_services.dart';
import 'package:buyers/widgets/cart/counter_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddToCartWidget extends StatefulWidget {
  const AddToCartWidget(this.document, {super.key});
  final DocumentSnapshot document;

  @override
  State<AddToCartWidget> createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  final CartServices _cart = CartServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _exist = false;
  late int _quantity = 1;
  late String _docId = '';
  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _cart.cart.doc(user!.uid).collection('products').get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId',
            isEqualTo:
                (widget.document.data() as Map<String, dynamic>)['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['productId'] ==
            widget.document.data() as Map<String, dynamic>) {
          ['productId'];
        }
        {
          setState(() {
            _exist = true;
            _quantity = doc['quantity'];
            _docId = doc.id;
          });
        }
      }
    });

    return _loading
        ? const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green),
              ),
            ),
          )
        : _exist
            ? CounterWidget(
                document: widget.document,
                quantity: _quantity,
                docId: _docId,
              )
            : InkWell(
                onTap: () {
                  EasyLoading.show(status: 'Adding...');
                  _cart.addToCart(widget.document).then((value) {
                    setState(() {
                      _exist = true;
                    });
                    EasyLoading.showSuccess('Added Successfully');
                  });
                },
                child: Container(
                  height: 50,
                  color: Colors.green,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Add to Basket',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
  }
}
