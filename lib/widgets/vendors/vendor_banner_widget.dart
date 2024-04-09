import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/services/store_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class VendorBanner extends StatefulWidget {
  const VendorBanner({super.key});
  @override
  State<VendorBanner> createState() => _VendorBannerState();
}

class _VendorBannerState extends State<VendorBanner> {
  late StoreServices _services;
  late List<DocumentSnapshot> _banners = [];
  late List<Widget> _imageWidgets = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _services = StoreServices();
  }

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _services.vendorBanner
          .where('sellerUid', isEqualTo: store.selectedStoreId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Container();
        }

        _banners = snapshot.data!.docs;

        _imageWidgets = _banners.map((banner) {
          Map<String, dynamic> getImage = banner.data() as Map<String, dynamic>;
          return Image.network(
            getImage['bannerUrl'],
            fit: BoxFit.cover,
          );
        }).toList();

        return Column(
          children: [
            CarouselSlider(
              items: _imageWidgets,
              options: CarouselOptions(
                viewportFraction: 1,
                initialPage: _currentIndex,
                // autoPlay: true,
                // autoPlayInterval: const Duration(seconds: 5),
                // autoPlayAnimationDuration: const Duration(milliseconds: 800),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
