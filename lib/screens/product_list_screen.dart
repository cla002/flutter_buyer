import 'package:buyers/providers/store_provider.dart';
import 'package:buyers/screens/product_by_category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  static const String id = 'product-list-screen';

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              storeData.selectedProductCategory,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: const [
          ProductListByCategory(),
        ],
      ),
    );
  }
}
