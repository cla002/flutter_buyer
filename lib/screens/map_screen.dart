// ignore_for_file: unused_field

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/auth_provider.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/screens/main_screen.dart';
import 'package:buyers/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String id = 'map-screen';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng currentLocation;
  late GoogleMapController _mapController;
  bool locating = false;
  bool _loggedIn = false;
  User? user;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        _loggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final auth = Provider.of<MyAuthProvider>(context);

    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 14.4746,
              ),
              zoomControlsEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(1.5, 20.8),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              mapToolbarEnabled: true,
              onCameraMove: (CameraPosition position) {
                setState(() {
                  locating = true;
                });
                locationData.onCameraMove(position);
              },
              onMapCreated: onCreated,
              onCameraIdle: () {
                setState(() {
                  locating = false;
                });
                locationData.getMoveCamera();
              },
            ),
            Center(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  "lib/images/marker.png",
                  color: Colors.green,
                ),
              ),
            ),
            const Center(
              child: SpinKitPulse(
                color: Colors.green,
                size: 100.0,
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                height: 180,
                color: Colors.white,
                width: GlobalStyles.screenWidth(context),
                child: Column(
                  children: [
                    locating
                        ? const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          )
                        : Container(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_searching),
                      label: locating
                          ? const Text('Locating...')
                          : Text(
                              locationData.selectedAddress?.featureName ??
                                  'Locating...',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    Text(locationData.selectedAddress?.addressLine ??
                        'Address Not Found'),
                    const SizedBox(
                      height: 20,
                    ),
                    AbsorbPointer(
                      absorbing: locating ? true : false,
                      child: FilledButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStatePropertyAll(
                              Size(GlobalStyles.screenWidth(context) - 40, 40)),
                          shape: const MaterialStatePropertyAll(
                            BeveledRectangleBorder(side: BorderSide.none),
                          ),
                        ),
                        onPressed: () {
                          //save address in shared preferences
                          locationData.savePrefs();
                          if (_loggedIn == false) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Please Login'),
                                content: const Text(
                                  'You need to login to continue.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, WelcomeScreen.id);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            auth.updateUser(
                              id: user!.uid,
                              // number: user!.phoneNumber,
                              latitude: locationData.latitude,
                              longitude: locationData.longitude,
                              address:
                                  locationData.selectedAddress!.addressLine!,
                            );
                            Navigator.pushReplacementNamed(
                                context, MainScreen.id);
                          }
                        },
                        child: const Text('Confirm Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
