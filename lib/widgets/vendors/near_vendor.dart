// ignore_for_file: unused_local_variable

import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/screens/vendor_home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyers/services/store_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class VendorNearYourCurrentLocation extends StatefulWidget {
  const VendorNearYourCurrentLocation({Key? key}) : super(key: key);

  @override
  State<VendorNearYourCurrentLocation> createState() =>
      _VendorNearYourCurrentLocationState();
}

class _VendorNearYourCurrentLocationState
    extends State<VendorNearYourCurrentLocation> {
  late double latitude = 0.0;
  late double longitude = 0.0;

  @override
  void didChangeDependencies() {
    final storeData = Provider.of<StoreProvider>(context);
    storeData.determinePosition().then((position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<StoreProvider>(context, listen: false).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    StoreServices services = StoreServices();

    final storeData = Provider.of<StoreProvider>(context);

    if (storeData.isLoading) {
      return Container();
    }

    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: StoreServices().getNearVendorToYourCurrentLocation(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.hasError) {
            return Container();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Vendors available near your current location'),
            );
          }

          // Calculate distances and sort the stores based on distance
          List<DocumentSnapshot> sortedStores =
              snapshot.data!.docs.where((document) {
            GeoPoint location = document['location'];
            double vendorLatitude = location.latitude;
            double vendorLongitude = location.longitude;

            double distance = Geolocator.distanceBetween(
              latitude, // Using the latitude set in didChangeDependencies
              longitude, // Using the longitude set in didChangeDependencies
              vendorLatitude,
              vendorLongitude,
            );
            double distanceInKm = distance / 1000;

            return distanceInKm <= 5;
          }).toList();

          sortedStores.sort((a, b) {
            GeoPoint locationA = a['location'];
            GeoPoint locationB = b['location'];

            double distanceA = Geolocator.distanceBetween(
              latitude, // Using the latitude set in didChangeDependencies
              longitude, // Using the longitude set in didChangeDependencies
              locationA.latitude,
              locationA.longitude,
            );

            double distanceB = Geolocator.distanceBetween(
              latitude, // Using the latitude set in didChangeDependencies
              longitude, // Using the longitude set in didChangeDependencies
              locationB.latitude,
              locationB.longitude,
            );

            return distanceA.compareTo(distanceB);
          });

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sortedStores.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = sortedStores[index];
              GeoPoint location = document['location'];
              double vendorLatitude = location.latitude;
              double vendorLongitude = location.longitude;

              double distance = Geolocator.distanceBetween(
                latitude, // Using the latitude set in didChangeDependencies
                longitude, // Using the longitude set in didChangeDependencies
                vendorLatitude,
                vendorLongitude,
              );
              double distanceInKm = distance / 1000;

              return InkWell(
                onTap: () {
                  print(document['uid']);
                  storeData.getSelectedStore(
                    document['shopName'],
                    document['uid'],
                    document['imageUrl'],
                    document['address'],
                    document['email'],
                    document['mobile'],
                    document['dialog'],
                  );
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context,
                    settings: const RouteSettings(name: VendorHomeScreen.id),
                    screen: VendorHomeScreen(document),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  width: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Card(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: document['imageUrl'],
                              placeholder: (context, url) => Container(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document['shopName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 63, 61, 61),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${distanceInKm.toStringAsFixed(2)}km',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
