// ignore_for_file: unused_field

import 'package:buyers/services/cart_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CounterForCard extends StatefulWidget {
  final DocumentSnapshot document;

  const CounterForCard(this.document, {super.key});

  @override
  State<CounterForCard> createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User? user = FirebaseAuth.instance.currentUser;
  final CartServices _cart = CartServices();
  late Stream<DocumentSnapshot?> _cartStream;
  late int _quantity;
  late String _docId;
  late double _total;
  bool _exists = false;
  bool _updating = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cartStream = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document['productId'])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot?>(
      stream: _cartStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else {
          final data = snapshot.data;
          if (data != null && data.exists) {
            _exists = true;
            _quantity = data['quantity'];
            _docId = data.id;
            _total = data['total'];
            return _buildCounter();
          } else {
            _exists = false;
            return _buildAddButton();
          }
        }
      },
    );
  }

  Widget _buildCounter() {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.purple.shade900,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: InkWell(
              onTap: () {
                _updateQuantity(_quantity - 1);
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3.0),
                  child: Icon(
                    _quantity == 1 ? Icons.delete : Icons.remove,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Container(
              color: Colors.purple.shade900,
              child: Center(
                child: _updating
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _updateQuantity(_quantity + 1);
            },
            child: SizedBox(
              width: 30,
              child: Container(
                child: const Icon(
                  Icons.add,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _loading = true;
        });
        EasyLoading.show(status: 'Adding...');
        _cart.checkSeller().then((shopName) {
          print((widget.document.data() as Map<String, dynamic>)['seller']
              ['shopName']);

          if (shopName ==
              (widget.document.data() as Map<String, dynamic>)['seller']
                  ['shopName']) {
            setState(() {
              _exists = true;
            });
            _cart.addToCart(widget.document).then((value) {
              EasyLoading.showSuccess('Product Added');
            });
            return;
          }

          if (shopName == null) {
            setState(() {
              _exists = true;
            });
            _cart.addToCart(widget.document).then((value) {
              EasyLoading.showSuccess('Product Added');
            });
            return;
          }
          if (shopName !=
              (widget.document.data() as Map<String, dynamic>)['seller']
                  ['shopName']) {
            EasyLoading.dismiss();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Replace Cart Item?'),
                  content: Text(
                      'Your Basket currently has an item from $shopName. Would you like to remove it and replace it with an item from ${(widget.document.data() as Map<String, dynamic>)['seller']['shopName']}?'),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        _cart.deleteCart().then((value) {
                          _cart.addToCart(widget.document).then(
                            (value) {
                              setState(() {
                                _exists = true;
                              });
                            },
                          );
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Yes',
                      ),
                    ),
                  ],
                );
              },
            );
          }
        });
      },
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container();
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _updating = true;
    });
    if (newQuantity == 0) {
      _cart.removeFromCart(_docId).then((value) {
        setState(() {
          _updating = false;
        });
        _cart.checkData();
        EasyLoading.dismiss();
      });
    } else {
      setState(() {
        _quantity = newQuantity;
      });
      _cart.updateCartQuantity(_docId, _quantity, _total).then((value) {
        setState(() {
          _updating = false;
        });
        EasyLoading.dismiss();
      });
    }
  }
}
