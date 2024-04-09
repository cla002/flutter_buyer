import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreServices {
  final CollectionReference vendorBanner =
      FirebaseFirestore.instance.collection('vendorBanner');
  final CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  getTopPickedStore() {
    return vendors
        .where('accountVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .snapshots();
  }

  getNearVendorToYourCurrentLocation() {
    return vendors.where('accountVerified', isEqualTo: true).snapshots();
  }

  getStoreList() {
    return vendors.where('approved', isEqualTo: true).snapshots();
  }

  getTopStores() {
    return vendors
        .where('approved', isEqualTo: true)
        .where('isTopPick', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getShopDetails(sellerUid) async {
    DocumentSnapshot snapshot = await vendors.doc(sellerUid).get();
    return snapshot;
  }

  void launchCall(String? number) async {
    if (number != null && number.isNotEmpty) {
      String url = 'tel:$number';
      await launch(url);
    } else {
      throw 'Phone number is invalid';
    }
  }

  void launchMap(GeoPoint location, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude), title: name);
  }
}

class categoryListServices {
  Stream<QuerySnapshot> getCategoryList() {
    return FirebaseFirestore.instance.collection('categories').snapshots();
  }
}

class categoryServices {
  static final List<String> _categoryName = [];

  getCategoryName() {
    return FirebaseFirestore.instance
        .collection('categories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      _categoryName.clear();
      for (var doc in querySnapshot.docs) {
        String categoryName = doc['categoryName'];
        _categoryName.add(categoryName);
      }
    });
  }

  static List<String> get categoryName => _categoryName;
}

class topStoreServices with ChangeNotifier {
  late String selectedStoreName = '';
  late String selectedStoreId = '';
  late String selectedStoreImage = "";
  late String selectedStoreAddress = "";
  late String selectedStoreDialog = "";
  late String selectedStoreEmail = "";
  late String selectedStorePhone = "";
  late bool selectedStoreTopPickedStatus;
  late bool selectedStoreOpen;
}
