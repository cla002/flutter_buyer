// // ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison, unused_field

// import 'package:buyers/globals/styles.dart';
// import 'package:buyers/providers/auth_provider.dart';
// import 'package:buyers/providers/cart_provider.dart';
// import 'package:buyers/providers/location_provider.dart';
// import 'package:buyers/screens/profile_screen.dart';
// import 'package:buyers/services/cart_services.dart';
// import 'package:buyers/services/order_services.dart';
// import 'package:buyers/services/user_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BottomSheetWidget extends StatefulWidget {
//   final DocumentSnapshot document;
//   const BottomSheetWidget(this.document, {super.key});

//   @override
//   _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
// }

// class _BottomSheetWidgetState extends State<BottomSheetWidget> {
//   final UserServices _userServices = UserServices();
//   User? user = FirebaseAuth.instance.currentUser;
//   final OrderServices _orderServices = OrderServices();
//   final CartServices _cartServices = CartServices();
//   int deliveryFee = 50;
//   String _address = '';
//   final bool _loading = false;
//   final bool _checkingUser = false;
//   double discount = 0;
//   final List _cartList = [];

//   //VOUCHER
//   Color color = Colors.grey;
//   final bool _enable = false;
//   final _couponText = TextEditingController();
//   final bool _visible = false;

//   @override
//   void initState() {
//     super.initState();
//     getPrefs();
//   }

//   void getPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? address = prefs.getString('address');

//     setState(() {
//       _address = address ?? 'Set Your Location';
//     });
//   }

//   String title = '';
//   String details = '';
//   double? discountRate;

//   @override
//   Widget build(BuildContext context) {
//     final locationData = Provider.of<LocationProvider>(context);
//     var userDetails = Provider.of<MyAuthProvider>(context);
//     userDetails.getUserDetails();

//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, _) {
//         var payable = cartProvider.subTotal - discount + deliveryFee;
//         return Container(
//           child: Column(
//             children: [
//               Container(
//                 height: 300,
//                 color: const Color.fromARGB(255, 248, 245, 245),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20.0,
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 EasyLoading.show(status: 'Please Wait...');
//                                 locationData.getCurrentPosition().then((value) {
//                                   if (value != null) {
//                                     EasyLoading.dismiss();
//                                     PersistentNavBarNavigator
//                                         .pushNewScreenWithRouteSettings(
//                                       context,
//                                       settings: const RouteSettings(
//                                           name: ProfileScreen.id),
//                                       screen: const ProfileScreen(),
//                                       withNavBar: false,
//                                       pageTransitionAnimation:
//                                           PageTransitionAnimation.cupertino,
//                                     );
//                                   } else {
//                                     EasyLoading.dismiss();
//                                     print('Permission not allowed');
//                                   }
//                                 });
//                               },
//                               child: _loading
//                                   ? const CircularProgressIndicator()
//                                   : const Text(
//                                       'Edit',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.green),
//                                     ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Text(
//                               'Receiver Name : ',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   if ((userDetails.snapshot?.data() as Map<
//                                               String, dynamic>)['firstName'] ==
//                                           null ||
//                                       (userDetails.snapshot?.data() as Map<
//                                               String, dynamic>)['lastName'] ==
//                                           null) {
//                                     // Redirect to profile screen
//                                     EasyLoading.show(status: 'Please Wait...');
//                                     locationData
//                                         .getCurrentPosition()
//                                         .then((value) {
//                                       if (value != null) {
//                                         EasyLoading.dismiss();
//                                         PersistentNavBarNavigator
//                                             .pushNewScreenWithRouteSettings(
//                                           context,
//                                           settings: const RouteSettings(
//                                               name: ProfileScreen.id),
//                                           screen: const ProfileScreen(),
//                                           withNavBar: false,
//                                           pageTransitionAnimation:
//                                               PageTransitionAnimation.cupertino,
//                                         );
//                                       } else {
//                                         EasyLoading.dismiss();
//                                         print('Permission not allowed');
//                                       }
//                                     });
//                                   }
//                                 },
//                                 child: Text(
//                                   userDetails.snapshot != null
//                                       ? '${(userDetails.snapshot!.data() as Map<String, dynamic>)['firstName'] ?? 'Set'} '
//                                           '${(userDetails.snapshot!.data() as Map<String, dynamic>)['lastName'] ?? 'Your Details'}'
//                                       : 'Set Your Details',
//                                   style: TextStyle(
//                                     color: (userDetails.snapshot?.data() as Map<
//                                                     String,
//                                                     dynamic>)['firstName'] ==
//                                                 null ||
//                                             (userDetails.snapshot?.data()
//                                                     as Map<String,
//                                                         dynamic>)['lastName'] ==
//                                                 null
//                                         ? Colors.red
//                                         : Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Delivery Address : ',
//                               style: TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                               child: Text(
//                                 _address == null
//                                     ? 'Set Your Location'
//                                     : _address,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 3,
//                                 style: TextStyle(
//                                   color: _address == null
//                                       ? Colors.red
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         const Divider(
//                           thickness: 2,
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         const Row(
//                           children: [
//                             Text(
//                               'Default Payment : ',
//                               style: TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               'CASH ON DELIVERY (COD)',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         SizedBox(
//                           width: GlobalStyles.screenWidth(context),
//                           child: Card(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 25.0, vertical: 12),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Details:',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15),
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                   Row(
//                                     children: [
//                                       const Expanded(
//                                         child: Text(
//                                           'Basket Value',
//                                           style: TextStyle(
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ),
//                                       Text(
//                                         '₱${cartProvider.subTotal}',
//                                         style: const TextStyle(
//                                             color: Colors.grey,
//                                             fontWeight: FontWeight.bold),
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                   Row(
//                                     children: [
//                                       const Expanded(
//                                         child: Text('Delivery Fee',
//                                             style: TextStyle(
//                                               color: Colors.grey,
//                                             )),
//                                       ),
//                                       Text(
//                                         '₱$deliveryFee',
//                                         style: const TextStyle(
//                                             color: Colors.grey,
//                                             fontWeight: FontWeight.bold),
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                   const Divider(
//                                     color: Colors.grey,
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                   Row(
//                                     children: [
//                                       const Expanded(
//                                         child: Text('Total Amount',
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold)),
//                                       ),
//                                       Text(
//                                         '₱$payable',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16),
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 50,
//                 color: Colors.purple.shade900,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Amount :   ₱${cartProvider.subTotal}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const Text(
//                               'With Tax : ',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 12),
//                             )
//                           ],
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Show confirmation dialog before placing the order
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text("Confirm Order"),
//                                 content: const Text(
//                                     "Are you sure you want to place the order?"),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: const Text("Cancel"),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                       _saveOrder(cartProvider, payable);
//                                     },
//                                     child: const Text("Confirm"),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.all<Color>(Colors.white),
//                           shape:
//                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5.0),
//                             ),
//                           ),
//                         ),
//                         child: const Text(
//                           'Check Out',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> updateStockQuantity(
//       String productId, int purchasedQuantity) async {
//     try {
//       DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .get();
//       int currentStockQuantity =
//           (productSnapshot.data() as Map<String, dynamic>)['stockQuantity'] ??
//               0;
//       int updatedStockQuantity = currentStockQuantity - purchasedQuantity;
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .update({
//         'stockQuantity': updatedStockQuantity,
//       });
//     } catch (error) {
//       print('Error updating stock quantity: $error');
//     }
//   }

//   Future<void> _saveOrder(CartProvider cartProvider, payable) async {
//     EasyLoading.show(status: 'Placing Order...');
//     // Fetch user details
//     DocumentSnapshot userDetailsSnapshot =
//         await _userServices.getUserById(user!.uid);
//     Map<String, dynamic> userDetailsData =
//         userDetailsSnapshot.data() as Map<String, dynamic>;
//     // Extract first name and last name
//     String firstName = userDetailsData['firstName'] ?? '';
//     String lastName = userDetailsData['lastName'] ?? '';
//     String address = userDetailsData['address'] ?? '';

//     if (firstName.isEmpty || lastName.isEmpty) {
//       EasyLoading.showError('Click "Set your details" to to Set your identity');
//       return;
//     }
//     if (address.isEmpty) {
//       EasyLoading.showError('Click "Set Your Location" to set your location');
//       return;
//     }
//     _orderServices.saveOrder({
//       'products': cartProvider.cartList,
//       'userId': user!.uid,
//       'deliveryFee': deliveryFee,
//       'total': payable,
//       'cod': cartProvider.cod,
//       'seller': {
//         'shopName':
//             (widget.document.data() as Map<String, dynamic>)['shopName'],
//         'sellerId':
//             (widget.document.data() as Map<String, dynamic>)['sellerUid'],
//       },
//       'timestamp': DateTime.now().toString(),
//       'orderStatus': 'Ordered',
//       'deliveryMan': {
//         'name': '',
//         'phone': '',
//         'location': '',
//       },
//       // Include first name and last name in order information
//       'firstName': firstName,
//       'lastName': lastName,
//     }).then((value) {
//       _cartServices.deleteCart().then((value) {
//         _cartServices.checkData().then((value) {
//           EasyLoading.showSuccess('Your order is submitted');
//           Navigator.pop(context);
//           for (var product in cartProvider.cartList) {
//             updateStockQuantity(product['productId'], product['quantity']);
//           }
//         });
//       });
//     });
//   }
// }

// ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison, unused_field

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/auth_provider.dart';
import 'package:buyers/providers/cart_provider.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/screens/profile_screen.dart';
import 'package:buyers/services/cart_services.dart';
import 'package:buyers/services/order_services.dart';
import 'package:buyers/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetWidget extends StatefulWidget {
  final DocumentSnapshot document;
  const BottomSheetWidget(this.document, {super.key});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;
  final OrderServices _orderServices = OrderServices();
  final CartServices _cartServices = CartServices();
  int deliveryFee = 50;
  String _address = '';
  final bool _loading = false;
  final bool _checkingUser = false;
  double discount = 0;
  final List _cartList = [];

  //VOUCHER
  Color color = Colors.grey;
  final bool _enable = false;
  final _couponText = TextEditingController();
  final bool _visible = false;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? address = prefs.getString('address');

    setState(() {
      _address = address ?? 'Set Your Location';
    });
  }

  String title = '';
  String details = '';
  double? discountRate;

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    var userDetails = Provider.of<MyAuthProvider>(context);
    userDetails.getUserDetails();

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        // Check if widget.document is null
        if (widget.document == null) {
          return Center(
            child: Text('Document snapshot is empty'),
          );
        }
        var payable = cartProvider.subTotal - discount + deliveryFee;
        return Container(
          child: Column(
            children: [
              Container(
                height: 300,
                color: const Color.fromARGB(255, 248, 245, 245),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                EasyLoading.show(status: 'Please Wait...');
                                locationData.getCurrentPosition().then((value) {
                                  if (value != null) {
                                    EasyLoading.dismiss();
                                    PersistentNavBarNavigator
                                        .pushNewScreenWithRouteSettings(
                                      context,
                                      settings: const RouteSettings(
                                          name: ProfileScreen.id),
                                      screen: const ProfileScreen(),
                                      withNavBar: false,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  } else {
                                    EasyLoading.dismiss();
                                    print('Permission not allowed');
                                  }
                                });
                              },
                              child: _loading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'Edit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green),
                                    ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Receiver Name : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if ((userDetails.snapshot?.data() as Map<
                                              String, dynamic>)['firstName'] ==
                                          null ||
                                      (userDetails.snapshot?.data() as Map<
                                              String, dynamic>)['lastName'] ==
                                          null) {
                                    // Redirect to profile screen
                                    EasyLoading.show(status: 'Please Wait...');
                                    locationData
                                        .getCurrentPosition()
                                        .then((value) {
                                      if (value != null) {
                                        EasyLoading.dismiss();
                                        PersistentNavBarNavigator
                                            .pushNewScreenWithRouteSettings(
                                          context,
                                          settings: const RouteSettings(
                                              name: ProfileScreen.id),
                                          screen: const ProfileScreen(),
                                          withNavBar: false,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      } else {
                                        EasyLoading.dismiss();
                                        print('Permission not allowed');
                                      }
                                    });
                                  }
                                },
                                child: Text(
                                  userDetails.snapshot != null &&
                                          userDetails.snapshot!.data() != null
                                      ? '${(userDetails.snapshot!.data() as Map<String, dynamic>)['firstName'] ?? 'Set'} '
                                          '${(userDetails.snapshot!.data() as Map<String, dynamic>)['lastName'] ?? 'Your Details'}'
                                      : 'Set Your Details',
                                  style: TextStyle(
                                    color: (userDetails.snapshot?.data()
                                                    as Map<String, dynamic>?) ==
                                                null ||
                                            (userDetails.snapshot?.data()
                                                        as Map<String, dynamic>)
                                                    .isEmpty ==
                                                true
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Address : ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                _address == null
                                    ? 'Set Your Location'
                                    : _address,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                  color: _address == null
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Divider(
                          thickness: 2,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Row(
                          children: [
                            Text(
                              'Default Payment : ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'CASH ON DELIVERY (COD)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: GlobalStyles.screenWidth(context),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Details:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Basket Value',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₱${cartProvider.subTotal}',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text('Delivery Fee',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            )),
                                      ),
                                      Text(
                                        '₱$deliveryFee',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text('Total Amount',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Text(
                                        '₱$payable',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                color: Colors.purple.shade900,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount :   ₱${cartProvider.subTotal}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'With Tax : ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Show confirmation dialog before placing the order
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Order"),
                                content: const Text(
                                    "Are you sure you want to place the order?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _saveOrder(cartProvider, payable);
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Check Out',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateStockQuantity(
      String productId, int purchasedQuantity) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      int currentStockQuantity =
          (productSnapshot.data() as Map<String, dynamic>)['stockQuantity'] ??
              0;
      int updatedStockQuantity = currentStockQuantity - purchasedQuantity;
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'stockQuantity': updatedStockQuantity,
      });
    } catch (error) {
      print('Error updating stock quantity: $error');
    }
  }

  Future<void> _saveOrder(CartProvider cartProvider, payable) async {
    EasyLoading.show(status: 'Placing Order...');
    // Fetch user details
    DocumentSnapshot userDetailsSnapshot =
        await _userServices.getUserById(user!.uid);
    Map<String, dynamic> userDetailsData =
        userDetailsSnapshot.data() as Map<String, dynamic>;
    // Extract first name and last name
    String firstName = userDetailsData['firstName'] ?? '';
    String lastName = userDetailsData['lastName'] ?? '';
    String address = userDetailsData['address'] ?? '';

    if (firstName.isEmpty || lastName.isEmpty) {
      EasyLoading.showError('Click "Edit" to to Set your identity');
      return;
    }
    if (address.isEmpty) {
      EasyLoading.showError('Click "Edit" to set your location');
      return;
    }
    _orderServices.saveOrder({
      'products': cartProvider.cartList,
      'userId': user!.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'cod': cartProvider.cod,
      'seller': {
        'shopName':
            (widget.document.data() as Map<String, dynamic>)['shopName'],
        'sellerId':
            (widget.document.data() as Map<String, dynamic>)['sellerUid'],
      },
      'timestamp': DateTime.now().toString(),
      'orderStatus': 'Ordered',
      'deliveryMan': {
        'name': '',
        'phone': '',
        'location': '',
      },
      // Include first name and last name in order information
      'firstName': firstName,
      'lastName': lastName,
    }).then((value) {
      _cartServices.deleteCart().then((value) {
        _cartServices.checkData().then((value) {
          EasyLoading.showSuccess('Your order is submitted');
          Navigator.pop(context);
          for (var product in cartProvider.cartList) {
            updateStockQuantity(product['productId'], product['quantity']);
          }
        });
      });
    });
  }
}
