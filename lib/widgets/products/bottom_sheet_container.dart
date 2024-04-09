import 'package:buyers/widgets/products/add_to_cart_widget.dart';
import 'package:buyers/widgets/products/save_to_favorite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer(this.document, {super.key});

  final DocumentSnapshot document;

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(flex: 1, child: SaveToFavorites(widget.document)),
          Flexible(flex: 1, child: AddToCartWidget(widget.document)),
        ],
      ),
    );
  }
}
