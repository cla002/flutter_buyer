import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  static const String id = 'my-orders';

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Successful Orders',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orders
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('orderStatus', isEqualTo: 'Delivered')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Successful Orders.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              List<dynamic> products = data['products'];

              // Extracting additional order details
              String timestamp = data['timestamp'].toString();
              String dateWithoutTime =
                  timestamp.split(' ')[0]; // Extracting only the date part

              String total = data['total'].toString();
              String shopName = data['seller']['shopName'].toString();

              // Check if the products list is not empty and has elements at the given index
              if (products.isNotEmpty) {
                // Display all products for the current order
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          'Shop Name: $shopName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Date: $dateWithoutTime'), // Only the date part is displayed
                            Text('Total: $total'),
                          ],
                        ),
                      ),
                      ...products.map<Widget>((product) {
                        return ListTile(
                          title: Text(product['productName'].toString()),
                          subtitle: Text("Quantity: ${product['quantity']}"),
                        );
                      }),
                      const Divider(), // Divider between orders
                    ],
                  ),
                );
              } else {
                return const SizedBox(); // Return an empty SizedBox if products list is empty
              }
            },
          );
        },
      ),
    );
  }
}
