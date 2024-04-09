import 'package:buyers/constants.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _controller = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;

  final List<Widget> _pages = [
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Image.asset('lib/images/feature1.png'),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Buy And Sell Local Products With E-Tabo',
            textAlign: TextAlign.center,
            style: kPageViewTextStyleTitle,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Discover and Buy Local Products through your smartphone.",
              textAlign: TextAlign.center, style: kPageViewTextStyle)
        ],
      ),
    ),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Image.asset('lib/images/feature2.png'),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Elevate your shopping experience with a commitment to Support Locals.',
            textAlign: TextAlign.center,
            style: kPageViewTextStyleTitle,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
              'Every purchase makes a positive impact on the people and places around you.',
              textAlign: TextAlign.center,
              style: kPageViewTextStyle),
        ],
      ),
    ),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Image.asset('lib/images/feature3.png'),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Dive into initiatives that foster community development',
            textAlign: TextAlign.center,
            style: kPageViewTextStyleTitle,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
              'Your contributions today pave the way for a brighter and more connected tomorrow.',
              textAlign: TextAlign.center,
              style: kPageViewTextStyle),
        ],
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: _pages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          DotsIndicator(
            dotsCount: _pages.length,
            position: _currentPage.toInt(),
            decorator: DotsDecorator(
              activeColor: Colors.green,
              size: const Size.square(9.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
          )
        ],
      ),
    );
  }
}
