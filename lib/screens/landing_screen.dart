// ignore_for_file: unnecessary_null_comparison, unused_field, no_leading_underscores_for_local_identifiers

import 'package:buyers/globals/styles.dart';
import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/screens/home_screen.dart';
import 'package:buyers/screens/map_screen.dart';
import 'package:buyers/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  static const String id = 'landing-screen';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final LocationProvider _locationProvider = LocationProvider();
  User? user = FirebaseAuth.instance.currentUser;
  late String _location = '';
  late String _address = '';

  @override
  void initState() {
    super.initState();
    UserServices _userServices = UserServices();
    _userServices.getUserById(user!.uid).then(
      (result) async {
        if (result != null && result.data() != null) {
          Map<String, dynamic> userData = result.data() as Map<String, dynamic>;
          if (userData['latitude'] != null) {
            getPrefs(userData);
          } else {
            _locationProvider.getCurrentPosition();
            if (_locationProvider.permissionAllowed == true) {
              Navigator.pushNamed(context, MapScreen.id);
            } else {
              print('Permission Not Allowed');
            }
          }
        }
      },
    );
  }

  getPrefs(dbResult) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    if (location == null) {
      prefs.setString('address', dbResult.data()['location']);
      prefs.setString('location', dbResult.data()['address']);
      if (mounted) {
        setState(() {
          _location = dbResult.data()['location'];
          _address = dbResult.data()['address'];
        });
      }
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.id);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_location),
            ),
            Text(_address == '' ? 'Address Not Set' : _address),
            Text(_address == '' ? 'Please Provide Your Address' : _address),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: FilledButton(
                style: ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(
                      Size(GlobalStyles.screenWidth(context), 40)),
                  shape: const MaterialStatePropertyAll(
                    BeveledRectangleBorder(side: BorderSide.none),
                  ),
                ),
                onPressed: () async {
                  _locationProvider.getCurrentPosition();
                  if (_locationProvider.permissionAllowed == true) {
                    Navigator.pushReplacementNamed(context, MapScreen.id);
                  } else {
                    print('Permission Not Allowed');
                  }
                },
                child: Text(_location != null
                    ? 'Update Your Location'
                    : 'Confirm Your Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
