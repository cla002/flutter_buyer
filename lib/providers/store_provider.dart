// ignore_for_file: unused_field, unnecessary_this

import 'package:buyers/screens/welcome_screen.dart';
import 'package:buyers/services/store_services.dart';
import 'package:buyers/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class StoreProvider with ChangeNotifier {
  final StoreServices _storeServices = StoreServices();
  final UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  bool isLoading = true;
  late String selectedStoreName = '';
  late String selectedStoreAddress = '';
  late String selectedStoreEmail = '';
  late String selectedStorePhone = '';
  late String selectedStoreImage = '';
  late String selectedStoreId = '';
  late String selectedStoreDialog = '';

  //Category
  late String selectedProductCategory;

  getSelectedStore(storeName, storeId, storeImage, storeAddress, storeEmail,
      storePhone, storeDialog) {
    this.selectedStoreName = storeName;
    this.selectedStoreId = storeId;
    this.selectedStoreImage = storeImage;
    this.selectedStoreAddress = storeAddress;
    this.selectedStoreEmail = storeEmail;
    this.selectedStorePhone = storePhone;
    this.selectedStoreDialog = storeDialog;

    notifyListeners();
  }

  selectedCategory(category) {
    this.selectedProductCategory = category;
    notifyListeners();
  }

  // Fetch user location data only once
  void init(BuildContext context) {
    getUserLocationData(context);
  }

  Future<void> getUserLocationData(BuildContext context) async {
    isLoading = true; // Set loading state
    notifyListeners();

    if (user != null) {
      _userServices.getUserById(user!.uid).then((result) {
        if (result.exists) {
          Map<String, dynamic> userData = result.data() as Map<String, dynamic>;
          userLatitude = userData['latitude'] ?? 0.0;
          userLongitude = userData['longitude'] ?? 0.0;
        } else {
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        }
        isLoading = false; // Set loading state to false after data fetch
        notifyListeners();
      });
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.id);
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
}
