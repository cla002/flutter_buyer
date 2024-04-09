// ignore_for_file: unnecessary_null_comparison, unnecessary_this, unnecessary_new, unused_local_variable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  late double latitude;
  late double longitude;
  bool permissionAllowed = false;
  var selectedAddress;
  bool loading = false;

  Future<bool> getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;

        permissionAllowed = true;
        notifyListeners();
        return true;
      } else {
        print('Position is null');
        return false; // Failure
      }
    } catch (e) {
      print('Error getting current position: $e');
      return false; // Failure
    }
  }

  void onCameraMove(CameraPosition cameraPosition) {
    latitude = cameraPosition.target.latitude;
    longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = new Coordinates(this.latitude, this.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    this.selectedAddress = addresses.first;
    print("${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }

  Future<void> savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', this.latitude);
    prefs.setDouble('longitude', this.longitude);
    prefs.setString('address', this.selectedAddress.addressLine);
    prefs.setString('location', this.selectedAddress.featureName);

    print(
        'Preferences saved: Latitude: $latitude, Longitude: $longitude, Address: ${this.selectedAddress.addressLine}');
  }
}
