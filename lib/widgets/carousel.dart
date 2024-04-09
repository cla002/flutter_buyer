import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:buyers/globals/styles.dart';

class CarouselSliderWidget extends StatefulWidget {
  const CarouselSliderWidget({Key? key}) : super(key: key);

  @override
  State<CarouselSliderWidget> createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  late Future<List<DocumentSnapshot>> _future;

  int _index = 0;
  int _dataLength = 1;

  @override
  void initState() {
    _future = getCarouselImagesFromFirestore();
    super.initState();
  }

  Future<List<DocumentSnapshot>> getCarouselImagesFromFirestore() async {
    var firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore.collection('banners').get();
      if (mounted) {
        setState(() {
          _dataLength = snapshot.docs.length;
        });
      }
      return snapshot.docs;
    } catch (e) {
      print("Error fetching carousel images: $e");

      if (mounted) {
        setState(() {
          _dataLength = 0;
        });
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_dataLength != 0)
          FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                // Handle the case when there's no data or an error occurred
                return const Text('No data available');
              } else {
                return SizedBox(
                  height: 200,
                  width: GlobalStyles.screenWidth(context),
                  child: CarouselSlider.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, int index, _) {
                      DocumentSnapshot carouselImage = snapshot.data![index];
                      Map<String, dynamic> getImage =
                          carouselImage.data() as Map<String, dynamic>;
                      final imageUrl = getImage['image'] as String;
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return const Placeholder();
                        },
                      );
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      onPageChanged: (int i, carouselPageChangeReason) {
                        setState(() {
                          _index = i;
                        });
                      },
                    ),
                  ),
                );
              }
            },
          ),
        if (_dataLength != 0)
          DotsIndicator(
            dotsCount: _dataLength,
            position: _index.toInt(),
            decorator: DotsDecorator(
              activeColor: Colors.green,
              size: const Size.square(5.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
      ],
    );
  }
}
