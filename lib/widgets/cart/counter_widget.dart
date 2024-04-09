// ignore_for_file: must_be_immutable

import 'package:buyers/services/cart_services.dart';
import 'package:buyers/widgets/products/add_to_cart_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  CounterWidget(
      {super.key, required this.document, required this.quantity, required this.docId});

  final DocumentSnapshot document;
  String docId;
  final int quantity;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final CartServices _cart = CartServices();
  late int _quantity;
  bool _updating = false;
  bool _exists = true;

  @override
  Widget build(BuildContext context) {
    // Set initial quantity from widget prop
    _quantity = widget.quantity;

    return _exists
        ? Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            height: 50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FittedBox(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                          });
                          if (_quantity == 1) {
                            _cart.removeFromCart(widget.docId).then((value) {
                              setState(() {
                                _updating = false;
                                _exists = false;
                              });
                            });
                            _cart.checkData();
                          }
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                            // Calculate new total
                            var total = _quantity *
                                (widget.document.data()
                                    as Map<String, dynamic>)['price'];
                            _cart
                                .updateCartQuantity(
                                    widget.docId, _quantity, total)
                                .then((value) {
                              setState(() {
                                _updating = false;
                              });
                            });
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.red),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _quantity == 1 ? Icons.delete : Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 8),
                          child: _updating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.purple),
                                  ),
                                )
                              : Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                      color: Colors.purple, fontSize: 16),
                                ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _updating = true;
                            _quantity++;
                          });
                          // Calculate new total
                          var total = _quantity *
                              (widget.document.data()
                                  as Map<String, dynamic>)['price'];

                          _cart
                              .updateCartQuantity(
                                  widget.docId, _quantity, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : AddToCartWidget(widget.document);
  }
}
