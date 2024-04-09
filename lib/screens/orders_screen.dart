// ignore_for_file: unused_local_variable

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/order_provider.dart';
import 'package:buyers/screens/main_screen.dart';
import 'package:buyers/services/order_services.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderServices _orderServices = OrderServices();
  User? user = FirebaseAuth.instance.currentUser;

  int tag = 1;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked Up',
    'On the Way',
    'Delivered',
    'Canceled',
    'Rejected'
  ];

  @override
  Widget build(BuildContext context) {
    var orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            width: GlobalStyles.screenWidth(context),
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) => setState(() {
                if (val == 0) {
                  orderProvider.status = null;
                }
                setState(() {
                  tag = val;
                  orderProvider.status = options[val];
                });
              }),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('userId', isEqualTo: user!.uid)
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.size == 0) {
                  return Center(
                    child: Column(
                      children: [
                        Text(tag > 0 ? 'No ${options[tag]} orders' : ''),
                        TextButton(
                            onPressed: () {
                              PersistentNavBarNavigator
                                  .pushNewScreenWithRouteSettings(
                                context,
                                settings: const RouteSettings(
                                    arguments: MainScreen.id),
                                screen: const MainScreen(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Text(
                              'Continue Shopping',
                              style: TextStyle(
                                  color: Colors.purple.shade900,
                                  fontWeight: FontWeight.w500),
                            ))
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  horizontalTitleGap: 0,
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 14,
                                    child: Icon(CupertinoIcons.square_list,
                                        size: 18),
                                  ),
                                  title: Text(
                                    (document.data()
                                        as Map<String, dynamic>)['orderStatus'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _orderServices
                                            .statusColor(document)),
                                  ),
                                  subtitle: Text(
                                    style: const TextStyle(fontSize: 12),
                                    'On ${DateFormat.yMMMMd().format(
                                      DateTime.parse(
                                        (document.data() as Map<String,
                                            dynamic>)['timestamp'],
                                      ),
                                    )}',
                                  ),
                                  trailing: (document.data() as Map<String,
                                              dynamic>)['orderStatus'] ==
                                          'Ordered'
                                      ? TextButton(
                                          onPressed: () {
                                            _orderServices
                                                .cancelOrder(document.id);
                                          },
                                          child: Text(
                                            'Cancel Order',
                                            style: TextStyle(
                                              color: Colors.orange.shade900,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Amount : ${(document.data() as Map<String, dynamic>)['total']}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54),
                                        ),
                                ),
                                //TODO: DELIVERY RIDER DETAILS
                                if ((document.data() as Map<String, dynamic>)[
                                            'deliveryMan']['name']
                                        .length >
                                    2)
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: (document.data() as Map<String,
                                                      dynamic>)['deliveryMan']
                                                  ['image'] ==
                                              null
                                          ? Container(
                                              child: const Text(
                                                'Not yet Accepted',
                                                style: TextStyle(fontSize: 8),
                                              ),
                                            )
                                          : Image.network(
                                              (document.data() as Map<String,
                                                      dynamic>)['deliveryMan']
                                                  ['image'],
                                            ),
                                    ),
                                    title: Text(
                                      (document.data() as Map<String, dynamic>)[
                                          'deliveryMan']['name'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    subtitle: Text(
                                      _orderServices.statusComment(document),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ExpansionTile(
                                  title: const Text(
                                    'Order Details',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: const Text(
                                    'View more details...',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Image.network(
                                                (document.data() as Map<String,
                                                        dynamic>)['products']
                                                    [index]['productImage']),
                                          ),
                                          title: Text(
                                            (document.data() as Map<String,
                                                    dynamic>)['products'][index]
                                                ['productName'],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'x',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                    (document.data() as Map<
                                                                    String,
                                                                    dynamic>)[
                                                                'products']
                                                            [index]['quantity']
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Price each : ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                    '₱${(document.data() as Map<String, dynamic>)['products'][index]['price'].toString()}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: (document.data() as Map<String,
                                              dynamic>)['products']
                                          .length,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 5.0),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Seller : ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                    (document.data() as Map<
                                                                    String,
                                                                    dynamic>)[
                                                                'seller']
                                                            ['shopName']
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Delivery Fee : ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                    (document.data() as Map<
                                                                String,
                                                                dynamic>)[
                                                            'deliveryFee']
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Total Amount : ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                    '${(document.data() as Map<String, dynamic>)['total']}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Payment Method : ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black54),
                                                  ),
                                                  if ((document.data() as Map<
                                                          String,
                                                          dynamic>)['cod'] ==
                                                      true)
                                                    const Text(
                                                      'Cash On Delivery',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  if ((document.data() as Map<
                                                          String,
                                                          dynamic>)['cod'] ==
                                                      false)
                                                    const Text(
                                                      'Gcash',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
