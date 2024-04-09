// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:buyers/providers/auth_provider.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/screens/map_screen.dart';
import 'package:buyers/screens/my_orders.dart';
import 'package:buyers/screens/update_profile_screen.dart';
import 'package:buyers/utils/logout_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile-screen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<MyAuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;
    userDetails.getUserDetails();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Account',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: 230,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 40,
                              child: userDetails.snapshot != null &&
                                      userDetails.snapshot!.data() != null &&
                                      (userDetails.snapshot!.data() as Map<
                                              String,
                                              dynamic>)['profilePicture'] !=
                                          null &&
                                      (userDetails.snapshot!.data() as Map<
                                              String,
                                              dynamic>)['profilePicture'] !=
                                          ''
                                  ? ClipOval(
                                      child: Image.network(
                                        (userDetails.snapshot!.data() as Map<
                                            String, dynamic>)['profilePicture'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color.fromARGB(255, 100, 99, 99),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Stack(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        (userDetails.snapshot != null &&
                                                (userDetails.snapshot!.data()
                                                            as Map<String,
                                                                dynamic>)[
                                                        'firstName'] !=
                                                    null &&
                                                (userDetails.snapshot!.data()
                                                            as Map<String,
                                                                dynamic>)[
                                                        'lastName'] !=
                                                    null)
                                            ? '${(userDetails.snapshot!.data() as Map<String, dynamic>)['firstName']} '
                                                '${(userDetails.snapshot!.data() as Map<String, dynamic>)['lastName']}'
                                            : 'Update Your Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        (userDetails.snapshot != null &&
                                                (userDetails.snapshot!.data()
                                                            as Map<String,
                                                                dynamic>)[
                                                        'email'] !=
                                                    null)
                                            ? '${(userDetails.snapshot!.data() as Map<String, dynamic>)['email']}'
                                            : 'Email',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 133, 130, 130),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        userDetails.snapshot != null &&
                                                userDetails.snapshot!.data() !=
                                                    null &&
                                                (userDetails.snapshot!.data()
                                                            as Map<String,
                                                                dynamic>)[
                                                        'number'] !=
                                                    null
                                            ? (userDetails.snapshot!.data()
                                                    as Map<String, dynamic>)[
                                                'number']
                                            : 'Phone Number Not Available',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 133, 130, 130),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  PersistentNavBarNavigator
                                      .pushNewScreenWithRouteSettings(
                                    context,
                                    settings: const RouteSettings(
                                        name: UpdateProfile.id),
                                    screen: const UpdateProfile(),
                                    withNavBar: false,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (userDetails.snapshot != null)
                        ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                          title: Text(
                            userDetails.snapshot != null &&
                                    userDetails.snapshot!.data() != null &&
                                    (userDetails.snapshot!.data() as Map<String,
                                            dynamic>)['address'] !=
                                        null
                                ? (userDetails.snapshot!.data()
                                    as Map<String, dynamic>)['address']
                                : 'Address Not Available',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: TextButton(
                              onPressed: () {
                                EasyLoading.show(status: 'Please Wait...');
                                locationData.getCurrentPosition().then((value) {
                                  if (value != null) {
                                    EasyLoading.dismiss();
                                    PersistentNavBarNavigator
                                        .pushNewScreenWithRouteSettings(
                                      context,
                                      settings: const RouteSettings(
                                          name: MapScreen.id),
                                      screen: const MapScreen(),
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
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green),
                              )),
                        ),
                      const Divider(
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text(
                  'My Order',
                  style: TextStyle(fontSize: 14),
                ),
                horizontalTitleGap: 10,
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context,
                    settings: const RouteSettings(arguments: MyOrders()),
                    screen: const MyOrders(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new_outlined),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 14),
                ),
                horizontalTitleGap: 10,
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
