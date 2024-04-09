import 'package:buyers/widgets/cart/counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartCard extends StatefulWidget {
  final DocumentSnapshot? document;
  const CartCard({super.key, required this.document});

  @override
  _CartCardState createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? data =
        widget.document?.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox();
    }

    final double price = data['price'];
    final double comparedPrice = data['comparedPrice'];
    final double saving = comparedPrice - price;
    final double offerValue =
        comparedPrice > 0 ? ((comparedPrice - price) / comparedPrice * 100) : 0;
    final String offer = offerValue.toStringAsFixed(0);

    return Container(
      height: 120,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 15.0,
        ),
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: data['productImage'] != null
                      ? Image.network(
                          data['productImage'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                        textAlign: TextAlign.center,
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
              padding: const EdgeInsets.only(left: 130.0, top: 5),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['productName'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Text(
                      data['unit'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                              color: Color.fromARGB(255, 134, 133, 133),
                              decoration: TextDecoration.lineThrough,
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
              child: isLoading
                  ? const CircularProgressIndicator()
                  : CounterForCard(widget.document!),
            ),
          ],
        ),
      ),
    );
  }
}
