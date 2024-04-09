import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add(data);
    return result;
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': 'Canceled',
      });
    } catch (error) {
      print('Error cancelling order: $error');
      throw Exception('Failed to cancel order');
    }
  }

  Color statusColor(DocumentSnapshot document) {
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Accepted') {
      return Colors.green;
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Rejected') {
      return Colors.red;
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Canceled') {
      return Colors.orange.shade900;
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Picked Up') {
      return Colors.yellow;
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'On the Way') {
      return Colors.blue;
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Delivered') {
      return Colors.purple.shade900;
    }
    return Colors.orangeAccent;
  }

  String statusComment(document) {
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Picked Up') {
      return "Your Order is Picked by ${(document.data() as Map<String, dynamic>)['deliveryMan']['name']}. You can contact our rider to this number: +63${(document.data() as Map<String, dynamic>)['deliveryMan']['phone']}";
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'On the Way') {
      return "Rider ${(document.data() as Map<String, dynamic>)['deliveryMan']['name']} is on the way to your location";
    }
    if ((document.data() as Map<String, dynamic>)['orderStatus'] ==
        'Delivered') {
      return "Your Order has been delivered by Rider, ${(document.data() as Map<String, dynamic>)['deliveryMan']['name']}";
    }
    return "Your Order is Accepted by ${(document.data() as Map<String, dynamic>)['seller']['shopName']}";
  }
}
